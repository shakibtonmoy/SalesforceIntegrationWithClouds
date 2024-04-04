@RestResource(urlMapping='/Account/*')
global with sharing class AccountWebService {
    global class AccountInfo{
        String accountId {get; set;}
        String accountName {get; set;}
        String phone {get; set;}
        String fax {get; set;}
        String accountNumber {get; set;}
        String website {get; set;}
        String industry {get; set;}
        String annualRevenue {get; set;}
        String errorMessage {get; set;}
    }

    global class RequestWrapper{
        String data {get; set;}
    }

    @httpGet
    global static List<AccountInfo> fetchAccounts() {
        System.debug('UserName From ORG: ' + UserInfo.getUserName());
        System.debug('User Id From ORG: ' + UserInfo.getUserId());
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String methodName = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<AccountInfo> accountInfoList = new List<AccountInfo>();
        if(methodName == 'fetchAccounts'){
            List<Account> accList = [SELECT Id, Name, Phone, Fax, AccountNumber, Website, Industry, AnnualRevenue FROM Account
                                    WHERE OwnerId =: UserInfo.getUserId()];

            for (Account acc : accList) {
                AccountInfo accInfo = new AccountInfo();
                accInfo.accountId = acc.Id;
                accInfo.accountName = acc.Name;
                accInfo.phone = acc.Phone;
                accInfo.fax = acc.Fax;
                accInfo.accountNumber = acc.AccountNumber;
                accInfo.website = acc.Website;
                accInfo.industry = acc.Industry;
                accInfo.annualRevenue = String.valueOf(acc.AnnualRevenue);
                
                accountInfoList.add(accInfo);
            }
        }if(methodName == 'fetchTasks'){
            
        }
        
        if(accountInfoList.size() > 0){
            return accountInfoList;
        }else{
            AccountInfo accInfo = new AccountInfo();
            accInfo.errorMessage = 'No data found';
            accountInfoList.add(accInfo);
            return accountInfoList;
        }
    }

    @httpPost
    global static String insertTextFile(){
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        RequestWrapper rw = (RequestWrapper)JSON.deserialize(requestString,RequestWrapper.class);
        System.debug('RequestWrapper: ' + rw);
        String dt = String.valueOf(Datetime.now());
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = dt + 'SampleTextFile.txt';
        conVer.Title = dt + 'SampleTextFile';
        conVer.VersionData = Blob.valueOf(rw.data);
        insert conVer;
        return 'Success';
    }
}