public enum AccessTokenProviderResult {
    
    case successed(access: String, refresh: String?)
    case failed(Error)
    
}
