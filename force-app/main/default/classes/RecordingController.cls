public with sharing class RecordingController {
    @AuraEnabled
    public static string insertFiles(String file){
        try {
            System.debug('Inside insertFile');
            System.debug('Base64Data: ' + file);
            String dt = String.valueOf(Datetime.now());
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
            conVer.PathOnClient = dt + 'Recorder.mp3'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = dt + 'Recorder '; // Display name of the files
            conVer.VersionData = EncodingUtil.base64Decode(file); // converting your binary string to Blog
            insert conVer;
            System.debug('ContentVersion Id: ' + conVer.Id);
            // First get the content document Id from ContentVersion
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;

            //Create ContentDocumentLink
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = '001F900001ixrTzIAI'; // you can use objectId,GroupId etc
            cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
            cDe.Visibility = 'AllUsers';
            insert cDe;
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void uploadAudioFile(String fileName, String base64Data) {
        // Convert base64 string to Blob
        Blob audioBlob = EncodingUtil.base64Decode(base64Data);
        
        // Create ContentVersion object to represent the audio file
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        cv.VersionData = audioBlob;
        cv.FirstPublishLocationId = '001F900001ixrTzIAI'; // Set the appropriate record Id where you want to attach the file
        
        insert cv;
    }
}