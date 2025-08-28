// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title TodoList
 * @dev A decentralized todo list application on the blockchain
 * @author Your Name
 */
contract TodoList {
    // Task structure
    struct Task {
        uint256 id;
        string content;
        bool completed;
        uint256 createdAt;
        address owner;
    }
    
    // State variables
    mapping(address => Task[]) private userTasks;
    mapping(address => uint256) private taskCounters;
    
    // Events
    event TaskCreated(address indexed user, uint256 indexed taskId, string content);
    event TaskCompleted(address indexed user, uint256 indexed taskId);
    event TaskDeleted(address indexed user, uint256 indexed taskId);
    
    // Modifiers
    modifier validTaskId(uint256 _taskId) {
        require(_taskId < userTasks[msg.sender].length, "Task does not exist");
        require(userTasks[msg.sender][_taskId].owner == msg.sender, "Not task owner");
        _;
    }
    
    /**
     * @dev Add a new task to the user's todo list
     * @param _content The content/description of the task
     */
    function addTask(string memory _content) public {
        require(bytes(_content).length > 0, "Task content cannot be empty");
        require(bytes(_content).length <= 500, "Task content too long");
        
        uint256 taskId = taskCounters[msg.sender];
        
        Task memory newTask = Task({
            id: taskId,
            content: _content,
            completed: false,
            createdAt: block.timestamp,
            owner: msg.sender
        });
        
        userTasks[msg.sender].push(newTask);
        taskCounters[msg.sender]++;
        
        emit TaskCreated(msg.sender, taskId, _content);
    }
    
    /**
     * @dev Mark a task as completed
     * @param _taskId The ID of the task to complete
     */
    function completeTask(uint256 _taskId) public validTaskId(_taskId) {
        require(!userTasks[msg.sender][_taskId].completed, "Task already completed");
        
        userTasks[msg.sender][_taskId].completed = true;
        
        emit TaskCompleted(msg.sender, _taskId);
    }
    
    /**
     * @dev Delete a task from the user's todo list
     * @param _taskId The ID of the task to delete
     */
    function deleteTask(uint256 _taskId) public validTaskId(_taskId) {
        uint256 lastIndex = userTasks[msg.sender].length - 1;
        
        // Move the last task to the deleted task's position
        if (_taskId != lastIndex) {
            userTasks[msg.sender][_taskId] = userTasks[msg.sender][lastIndex];
            userTasks[msg.sender][_taskId].id = _taskId;
        }
        
        // Remove the last element
        userTasks[msg.sender].pop();
        
        emit TaskDeleted(msg.sender, _taskId);
    }
    
    /**
     * @dev Get all tasks for the calling user
     * @return Array of all user's tasks
     */
    function getTasks() public view returns (Task[] memory) {
        return userTasks[msg.sender];
    }
    
    /**
     * @dev Get a specific task by ID
     * @param _taskId The ID of the task to retrieve
     * @return The requested task
     */
    function getTask(uint256 _taskId) public view validTaskId(_taskId) returns (Task memory) {
        return userTasks[msg.sender][_taskId];
    }
    
    /**
     * @dev Get the total number of tasks for the calling user
     * @return The total task count
     */
    function getTaskCount() public view returns (uint256) {
        return userTasks[msg.sender].length;
    }
    
    /**
     * @dev Get the number of completed tasks for the calling user
     * @return The completed task count
     */
    function getCompletedTaskCount() public view returns (uint256) {
        uint256 completedCount = 0;
        Task[] memory tasks = userTasks[msg.sender];
        
        for (uint256 i = 0; i < tasks.length; i++) {
            if (tasks[i].completed) {
                completedCount++;
            }
        }
        
        return completedCount;
    }
    
    /**
     * @dev Get only pending (incomplete) tasks
     * @return Array of pending tasks
     */
    function getPendingTasks() public view returns (Task[] memory) {
        Task[] memory allTasks = userTasks[msg.sender];
        uint256 pendingCount = allTasks.length - getCompletedTaskCount();
        
        Task[] memory pendingTasks = new Task[](pendingCount);
        uint256 index = 0;
        
        for (uint256 i = 0; i < allTasks.length; i++) {
            if (!allTasks[i].completed) {
                pendingTasks[index] = allTasks[i];
                index++;
            }
        }
        
        return pendingTasks;
    }
}
