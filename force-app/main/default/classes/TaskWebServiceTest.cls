@isTest
public with sharing class TaskWebServiceTest {
    @isTest
    static void testFetchTasks_WithData() {
        // Create and insert a test Account and Contact
        Account testAccount = new Account(Name = 'Test Account');
        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = testAccount.Id);
        insert testAccount;
        insert testContact;

        // Create and insert a test Task associated with the test Account and Contact
        Task testTask = new Task(
            Subject = 'Test Task',
            Status = 'Not Started',
            AudioURL__c = 'www.audio.com',
            VideoURL__c = 'www.video.com',
            STTURL__c = 'www.stt.com',
            WhatId = testAccount.Id,
            WhoId = testContact.Id
        );
        insert testTask;

        // Start and stop the test context
        Test.startTest();

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/TaskInfo/fetchTasks';
        RestContext.request = req;
        // Call the fetchTasks() method
        List<TaskWebService.TaskInfo> taskInfoList = TaskWebService.fetchTasks();
        System.debug('List size: ' + taskInfoList.size());
        System.debug('Task Info: ' + taskInfoList);

        // Stop the test context
        Test.stopTest();

        // Assert the expected results
        System.assertEquals(1, taskInfoList.size());
        TaskWebService.TaskInfo taskInfo = taskInfoList[0];
        System.assertEquals(testTask.Id, taskInfo.taskId);
        System.assertEquals(testTask.Subject, taskInfo.taskSubject);
        System.assertEquals(testTask.Status, taskInfo.taskStatus);
        System.assertEquals(testTask.AudioURL__c, taskInfo.audioUrl);
        System.assertEquals(testTask.VideoURL__c, taskInfo.videoUrl);
        System.assertEquals(testTask.STTURL__c, taskInfo.sttUrl);
    }

    @IsTest
    static void testFetchTasks_WithNoData() {
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/TaskInfo/fetchTasks';
        RestContext.request = req;
        // Call the fetchTasks() method
        List<TaskWebService.TaskInfo> taskInfoList = TaskWebService.fetchTasks();
        System.debug('List size: ' + taskInfoList.size());
        System.debug('Task Info: ' + taskInfoList);
        Test.stopTest();
        System.assertEquals('No data found for this user', taskInfoList[0].errorMessage);
    }

    @IsTest
    static void testFetchTasksTestWithException() {
        Test.startTest();
        // Call the fetchTasks() method
        List<TaskWebService.TaskInfo> taskInfoList = TaskWebService.fetchTasks();
        System.debug('List size: ' + taskInfoList.size());
        System.debug('Task Info: ' + taskInfoList);
        Test.stopTest();
        System.assert(taskInfoList[0].errorMessage != null);
    }

    @isTest
    static void testUpdateTask_Positive() {
        // Test data setup
        Task testTask = new Task(Subject = 'Test Task', Status = 'In Progress');
        insert testTask;

        // Prepare request body
        TaskWebService.RequestWrapper request = new TaskWebService.RequestWrapper();
        request.taskId = testTask.Id;
        request.audioUrl = 'Updated Audio URL';
        request.videoUrl = 'Updated Video URL';
        request.sttUrl = 'Updated STT URL';

        // Mock the request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Task/updateTask';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(request));
        RestContext.request = req;

        // Call the HTTP POST method
        Test.startTest();
        TaskWebService.ResultWrapper result = TaskWebService.updateTask();
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(null, result.message, 'Message should not be null');
        System.assertEquals(null, result.hasError, 'There should not be an error');
        System.assertEquals('Task is updated successfully', result.message, 'Message should indicate successful update');
        System.assertEquals(testTask.Id, result.taskId, 'Task Id should match');
        System.assertEquals(request.audioUrl, result.audioUrl, 'Audio URL should match');
        System.assertEquals(request.videoUrl, result.videoUrl, 'Video URL should match');
        System.assertEquals(request.sttUrl, result.sttUrl, 'STT URL should match');
    }

    @isTest
    static void testUpdateTask_Negative_NoTaskId() {
        // Prepare request body without taskId
        TaskWebService.RequestWrapper request = new TaskWebService.RequestWrapper();
        request.audioUrl = 'Updated Audio URL';
        request.videoUrl = 'Updated Video URL';
        request.sttUrl = 'Updated STT URL';

        // Mock the request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Task/updateTask';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(request));
        RestContext.request = req;

        // Call the HTTP POST method
        Test.startTest();
        TaskWebService.ResultWrapper result = TaskWebService.updateTask();
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(null, result.message, 'Message should not be null');
        System.assertEquals(true, result.hasError, 'There should be an error');
        System.assertEquals('No task record found. Please provide a valid taskId', result.message, 'Message should indicate missing taskId');
    }

    @isTest
    static void testUpdateTask_Negative_NoTaskRecord() {
        // Prepare request body with a non-existent taskId
        TaskWebService.RequestWrapper request = new TaskWebService.RequestWrapper();
        request.taskId = 'NonExistentTaskId';
        request.audioUrl = 'Updated Audio URL';
        request.videoUrl = 'Updated Video URL';
        request.sttUrl = 'Updated STT URL';

        // Mock the request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Task/updateTask';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(request));
        RestContext.request = req;

        // Call the HTTP POST method
        Test.startTest();
        TaskWebService.ResultWrapper result = TaskWebService.updateTask();
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(null, result.message, 'Message should not be null');
        System.assertEquals(true, result.hasError, 'There should be an error');
        System.assertEquals('No task record found. Please provide a valid taskId', result.message, 'Message should indicate missing taskId');
    }

    @isTest
    static void testUpdateTask_Negative_ExceptionHandling() {
        // Setup: Simulate an exception during execution
        RestRequest req = new RestRequest();
        RestContext.request = req;
        req.requestURI = '/services/apexrest/Task/updateTask';

        // Call the HTTP POST method
        Test.startTest();
        TaskWebService.ResultWrapper result = TaskWebService.updateTask();
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(null, result.message, 'Message should not be null');
        System.assertEquals(true, result.hasError, 'There should be an error');
    }

    @isTest
    static void testUpdateTask_CreateTextFile() {
        // Test data setup
        Task testTask = new Task(Subject = 'Test Task', Status = 'In Progress');
        insert testTask;

        // Prepare request body
        TaskWebService.RequestWrapper request = new TaskWebService.RequestWrapper();
        request.taskId = testTask.Id;
        request.taskSubject = testTask.Subject;
        request.data = 'This a sample text data to test createTextFile method';

        // Mock the request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Task/createTextFile';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(request));
        RestContext.request = req;

        // Call the HTTP POST method
        Test.startTest();
        TaskWebService.ResultWrapper result = TaskWebService.updateTask();
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(null, result.message, 'Message should not be null');
        System.assertEquals(null, result.hasError, 'There should not be an error');
        System.assertEquals('Text File is created successfully', result.message, 'Message should indicate successful file creation');
    }
}