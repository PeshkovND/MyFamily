import Foundation
import BackgroundTasks

public class BackgroundTasksManager {
    private let scheduler = BGTaskScheduler.shared
    
    public func cancelTask(backgroundTaskId: String) {
        scheduler.cancel(taskRequestWithIdentifier: backgroundTaskId)
    }
    
    public func registerTask(backgroundTaskId: String, handleTask: @escaping (BGProcessingTask) -> Void) {
        scheduler.register(forTaskWithIdentifier: backgroundTaskId, using: DispatchQueue.global()) { task in
            guard let task = task as? BGProcessingTask else { return }
            handleTask(task)
        }
    }
    
    public func scheduleNewTask(backgroundTaskId: String) {
        scheduler.getPendingTaskRequests { requests in
            guard requests.isEmpty else { return }
            
            do {
                let newTask = BGProcessingTaskRequest(identifier: backgroundTaskId)
                try self.scheduler.submit(newTask)
            } catch {
                print("Could not schedule new task: \(error)")
            }
        }
    }
    
    public init() {}
}
