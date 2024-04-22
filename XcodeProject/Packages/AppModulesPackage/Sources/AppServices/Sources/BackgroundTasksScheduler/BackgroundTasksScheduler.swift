//  

import Foundation
import BackgroundTasks

public class BackgroundTasksManager {
    public func cancelTask(backgroundTaskId: String) {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskId)
    }
    
    public func registerTask(backgroundTaskId: String, handleTask: @escaping (BGProcessingTask) -> Void) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskId, using: DispatchQueue.global()) { task in
            guard let task = task as? BGProcessingTask else { return }
            handleTask(task)
        }
    }
    
    public func scheduleNewTask(backgroundTaskId: String) {
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            guard requests.isEmpty else { return }
            
            do {
                let newTask = BGProcessingTaskRequest(identifier: backgroundTaskId)
                try BGTaskScheduler.shared.submit(newTask)
            } catch {
                print("Could not schedule new task: \(error)")
            }
        }
    }
    
    public init() {}
}
