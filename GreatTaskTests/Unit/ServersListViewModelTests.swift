//
//  ServersListViewModelTests.swift
//  GreatTaskTests
//

import Testing
@testable import GreatTask

@MainActor
@Suite("ServersListViewModel")
struct ServersListViewModelTests {

    private func makeSUT() -> (ServersListViewModel, FakeDataService) {
        let dataService = FakeDataService()
        return (ServersListViewModel(dataService: dataService), dataService)
    }

    private func load(_ viewModel: ServersListViewModel) async {
        viewModel.loadServers()
        await viewModel.loadTask?.value
    }

    // MARK: - Sorting

    @Test("names sort naturally, not lexicographically")
    func sortsNamesNaturally() async {
        let (viewModel, dataService) = makeSUT()
        dataService.fetchResult = .success([
            ServerModel(name: "server-10", distance: 1),
            ServerModel(name: "server-2", distance: 2),
            ServerModel(name: "Ätna", distance: 3),
            ServerModel(name: "amsterdam", distance: 4),
        ])
        await load(viewModel)

        #expect(viewModel.sortedServers.map(\.name) == ["amsterdam", "Ätna", "server-2", "server-10"])

        viewModel.toggleSort(.name)

        #expect(viewModel.sortedServers.map(\.name) == ["server-10", "server-2", "Ätna", "amsterdam"])
    }

    @Test("distance sorts numerically in both directions")
    func sortsByDistance() async {
        let (viewModel, dataService) = makeSUT()
        dataService.fetchResult = .success([
            ServerModel(name: "b", distance: 300),
            ServerModel(name: "a", distance: 20),
            ServerModel(name: "c", distance: 1000),
        ])
        await load(viewModel)

        viewModel.toggleSort(.distance)
        #expect(viewModel.sortedServers.map(\.distance) == [20, 300, 1000])

        viewModel.toggleSort(.distance)
        #expect(viewModel.sortedServers.map(\.distance) == [1000, 300, 20])
    }

    @Test("toggling the same field flips order, switching fields resets to ascending")
    func toggleSortSemantics() {
        let (viewModel, _) = makeSUT()

        #expect(viewModel.sortField == .name)
        #expect(viewModel.sortOrder == .ascending)

        viewModel.toggleSort(.name)
        #expect(viewModel.sortOrder == .descending)

        viewModel.toggleSort(.distance)
        #expect(viewModel.sortField == .distance)
        #expect(viewModel.sortOrder == .ascending)
    }

    // MARK: - Loading

    @Test("a cold start shows the loading state until the fetch lands")
    func coldStartShowsLoading() async {
        let (viewModel, dataService) = makeSUT()
        let probe = Probe()
        dataService.cached = []
        dataService.fetchResult = .success([ServerModel(name: "a", distance: 1)])
        dataService.onFetch = { [weak viewModel] in
            probe.isLoading = viewModel?.isLoading
            probe.isRefreshing = viewModel?.isRefreshing
        }

        #expect(viewModel.isLoading)
        await load(viewModel)

        #expect(probe.isLoading == true)
        #expect(probe.isRefreshing == false)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.sortedServers.map(\.name) == ["a"])
    }

    @Test("a warm cache renders immediately and refreshes in the background")
    func warmCacheRendersBeforeRefresh() async {
        let (viewModel, dataService) = makeSUT()
        let probe = Probe()
        dataService.cached = [ServerModel(name: "cached", distance: 1)]
        dataService.fetchResult = .success([ServerModel(name: "fresh", distance: 2)])
        dataService.onFetch = { [weak viewModel] in
            probe.isLoading = viewModel?.isLoading
            probe.isRefreshing = viewModel?.isRefreshing
            probe.names = viewModel?.sortedServers.map(\.name) ?? []
        }

        await load(viewModel)
        
        #expect(probe.isLoading == false)
        #expect(probe.isRefreshing == true)
        #expect(probe.names == ["cached"])

        #expect(viewModel.sortedServers.map(\.name) == ["fresh"])
        #expect(viewModel.isRefreshing == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("a failed refresh keeps the cached rows and shows the stale banner")
    func failedRefreshKeepsCachedRows() async {
        let (viewModel, dataService) = makeSUT()
        dataService.cached = [ServerModel(name: "cached", distance: 1)]
        dataService.fetchResult = .failure(TestError.boom)

        await load(viewModel)

        #expect(viewModel.sortedServers.map(\.name) == ["cached"])
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isRefreshing == false)
    }

    @Test("a failed first load with no cache surfaces the error alone")
    func failedColdLoadShowsErrorOnly() async {
        let (viewModel, dataService) = makeSUT()
        dataService.cached = []
        dataService.fetchResult = .failure(TestError.boom)

        await load(viewModel)

        #expect(viewModel.sortedServers.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }

    /// `ServersListView.onAppear` fires on every return to the list, so this guard matters.
    @Test("overlapping loads coalesce into a single fetch")
    func overlappingLoadsCoalesce() async {
        let (viewModel, dataService) = makeSUT()
        dataService.fetchResult = .success([ServerModel(name: "a", distance: 1)])

        viewModel.loadServers()
        let task = viewModel.loadTask
        viewModel.loadServers()
        viewModel.loadServers()
        await task?.value

        #expect(dataService.fetchCount == 1)
    }
}
