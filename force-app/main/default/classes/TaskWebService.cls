@RestResource(urlMapping='/Task/*')
global with sharing class TaskWebService {

    global class TaskInfo{
        public String taskId {get; set;}
        public String taskSubject {get; set;}
        public String taskStatus {get; set;}
        public String audioUrl {get; set;}
        public String videoUrl {get; set;}
        public String sttUrl {get; set;}
        public String errorMessage {get; set;}
    }

    global class RequestWrapper{
        public String data {get; set;}
        public String taskId {get; set;}
        public String audioUrl {get; set;}
        public String videoUrl {get; set;}
        public String sttUrl {get; set;}
        public String taskSubject {get; set;}
    }

    global class ResultWrapper{
        public String message {get; set;}
        public Boolean hasError {get; set;}
        public String taskId {get; set;}
        public String audioUrl {get; set;}
        public String videoUrl {get; set;}
        public String sttUrl {get; set;}
        public String stackTraceString{get; set;}
        // String taskSubject {get; set;}
    }

    @httpGet
    global static List<TaskInfo> fetchTasks() {
        System.debug('UserName From ORG: ' + UserInfo.getUserName());
        System.debug('User Id From ORG: ' + UserInfo.getUserId());
        List<TaskInfo> taskInfoList = new List<TaskInfo>();
        try {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String methodName = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            if(methodName == 'fetchTasks'){
                List<Task> taskList = [
                    SELECT Id, Status, Subject, VideoURL__c, AudioURL__c, STTURL__c FROM Task 
                    WHERE OwnerId =: UserInfo.getUserId() 
                    AND What.Type = 'Account' 
                    AND Who.Type = 'Contact' 
                    AND Status != 'Completed'
                ];

                for (Task t : taskList) {
                    TaskInfo taskInfo = new TaskInfo();
                    taskInfo.taskId = t.Id;
                    taskInfo.taskSubject = t.Subject;
                    taskInfo.taskStatus = t.Status;
                    taskInfo.audioUrl = t.AudioURL__c;
                    taskInfo.videoUrl = t.VideoURL__c;
                    taskInfo.sttUrl = t.STTURL__c;
                    
                    taskInfoList.add(taskInfo);
                }
            }
            
            if(taskInfoList.size() > 0){
                return taskInfoList;
            }else{
                TaskInfo taskInfo = new TaskInfo();
                taskInfo.errorMessage = 'No data found for this user';
                taskInfoList.add(taskInfo);
                return taskInfoList;
            }
        } catch (Exception e) {
            taskInfoList.clear();
            TaskInfo taskInfo = new TaskInfo();
            taskInfo.errorMessage = e.getMessage() + '\n' + e.getStackTraceString();
            taskInfoList.add(taskInfo);
            return taskInfoList;
        }
    }

    @httpPost
    global static ResultWrapper updateTask(){
        ResultWrapper resultWrapper = new ResultWrapper();
        resultWrapper.message = 'No matched data found';
        try {
            RestRequest req = RestContext.request;
            String methodName = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            Blob body = req.requestBody;
            String requestString = body.toString();
            RequestWrapper rw = (RequestWrapper)JSON.deserialize(requestString,RequestWrapper.class);
            System.debug('Method Name: ' + methodName);
            if(methodName == 'updateTask'){
                System.debug('RequestWrapper: ' + rw);
                System.debug('Task Id: ' + rw.taskId);
                List<Task> taskList = [
                    SELECT Id, Status, Subject, AudioURL__c, VideoURL__c, STTURL__c FROM Task 
                    WHERE Id =: rw.taskId LIMIT 1
                ];

                if(taskList.size() > 0){
                    for(Task t: taskList){
                        t.AudioURL__c = rw.audioUrl != null ? rw.audioUrl : t.AudioURL__c;
                        t.VideoURL__c = rw.videoUrl != null ? rw.videoUrl : t.VideoURL__c;
                        t.STTURL__c = rw.sttUrl != null ? rw.sttUrl : t.STTURL__c;
                    }

                    Database.SaveResult[] srList = Database.update(taskList, false);
                    // Iterate through each returned result
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            // Operation was successful
                            resultWrapper.message = 'Task is updated successfully';
                            resultWrapper.taskId = taskList[0].Id;
                            resultWrapper.audioUrl = taskList[0].AudioURL__c;
                            resultWrapper.videoUrl = taskList[0].VideoURL__c;
                            resultWrapper.sttUrl = taskList[0].STTURL__c;
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred: ' + err.getMessage());
                                resultWrapper.message = 'The following error has occurred: ' + err.getMessage();
                                resultWrapper.hasError = true;
                            }
                        }
                    }
                }else{
                    resultWrapper.message = 'No task record found. Please provide a valid taskId';
                    resultWrapper.hasError = true;
                }
            }else if(methodName == 'createTextFile'){
                String dt = String.valueOf(Datetime.now());
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S';
                conVer.PathOnClient = dt + rw.taskSubject + '.txt';
                conVer.Title = dt + rw.taskSubject + '.txt';
                conVer.VersionData = Blob.valueOf(rw.data);
                insert conVer;

                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;

                System.debug('Task Id: ' + rw.taskId);
                //Create ContentDocumentLink
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = conDoc;
                cDe.LinkedEntityId = rw.taskId;
                cDe.ShareType = 'I';
                cDe.Visibility = 'AllUsers';
                insert cDe;
                resultWrapper.message = 'Text File is created successfully';
            }
            return resultWrapper;

        } catch (Exception e) {
            resultWrapper.message = e.getMessage();
            resultWrapper.hasError = true;
            resultWrapper.stackTraceString = e.getStackTraceString();
            return resultWrapper;
        }
    }
}