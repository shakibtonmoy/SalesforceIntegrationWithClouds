public with sharing class AWSService {
    
    public string awsKey {get;set;}
    public string awsSecret {get;set;}
    public string bucketName {get;set;}
    public string methodName {get;set;}
    public string hostName {get;set;}
    
    public AWSService(string key, string secret, string bucket, string method, string host)
    {
        awsKey=key;
        awsSecret=secret;
        bucketName=bucket;
        methodName=method;
        hostName=host;
    }
    
    public string ContentType(string fileType)
    {
        switch on fileType.toLowerCase()
        {
            when 'docx'
            {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'csv'
            {
                return 'application/vnd.ms-excel';
            }
            when 'wav'
            {
                return 'audio/wav';
            }
            when 'wmv'
            {
                return 'video/x-ms-wmv';
            }
            when 'mp3'
            {
                return 'audio/mpeg';
            }
            when 'mp4'
            {
                return 'video/mp4';
            }
            when 'png'
            {
                return 'image/png';
                
            }
            when 'pdf'
            {
                return 'application/pdf';
                
            }
            when else {
                return 'image/jpeg';
            }
        }
    }
    
    public string CreateAuthHeader( String contentType,
                                    String filename, String formattedDateString,string fileExtension){
                                        string auth;
                                        String stringToSign = this.methodName+'\n\n'+contentType+'\n'+formattedDateString+'\n/'+this.bucketName+'/'+filename.toLowerCase()+ '.'+fileExtension.toLowerCase();
                                        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(this.awsSecret));
                                        String sig = EncodingUtil.base64Encode(mac);
                                        auth = 'AWS' + ' ' + this.awsKey + ':' + sig;
                                        return auth;
                                    }
    
    
    public void UploadDocuments(string recordId)
    {
        if(string.isBlank(this.awsSecret) || string.isBlank(this.awsKey) || string.isBlank(this.bucketName) || string.isBlank(this.hostName))
        {
            throw new BaseException('Set AWS credential');
        }
        List<ContentDocumentLink> links=[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId=:recordId];
        Set<Id> ids=new Set<Id>();
        for(ContentDocumentLink link:links)
        {
            ids.add(link.ContentDocumentId);
        }
        List<ContentVersion> versions=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId = :ids AND IsLatest = true];
        
        for(ContentVersion attach:versions)
        {
            //File Content
            String attachmentBody = EncodingUtil.base64Encode(attach.VersionData);
            String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
            
            String filename = attach.Title;
            System.debug(attach.FileExtension);
            string contentType=ContentType(attach.FileExtension);
            system.debug('contentType:'+contentType);
            
            string fileUrl='https://' + this.bucketName + '.' + this.hostName + '/' + filename.toLowerCase()+ '.'+attach.FileExtension.toLowerCase();
            HttpRequest req = new HttpRequest();
            req.setMethod(this.methodName);
            req.setEndpoint(fileUrl);
            req.setHeader('Host', this.bucketName + '.' + this.hostName);
            req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
            req.setHeader('Content-Encoding', 'UTF-8');
            req.setHeader('Content-type', contentType);
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('Date', formattedDateString);
            req.setHeader('ACL', 'public-read');
            Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
            req.setBodyAsBlob(pdfBlob);

            req.setHeader('Authorization',CreateAuthHeader(contentType, filename, formattedDateString,attach.FileExtension));
            System.debug('Endpoint: ' + fileUrl);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Status Code: '+ res.getStatusCode());
            if (res.getStatusCode() == 200 || res.getStatusCode()==201) 
            {
                //Store Information in Object
                //Will be used for retrieving files
                // FileStore__c fileStore=new FileStore__c();
                // fileStore.S3ServerUrl__c=fileUrl;
                // fileStore.Name=filename+'.'+  attach.FileExtension.toLowerCase();
                // fileStore.RecordId__c=recordId;
                // fileStore.FileExtension__c=attach.FileExtension.toLowerCase();
                // insert fileStore;
                System.debug('File Uploaded successfully');
            }
        }
    }
    
}