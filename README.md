# Swift-Network-Layer
This repo provide you a single network class in Swift. It's very helpful when you want to handle API in your SDK or Framework that you don't want your Framework belong to another network framework

# How to use?
Just drag Request.swift to your project. You can rename it to your coding convention rule. 
Then just call             Request().request(withURL: url, method: HTTPMethod.post, params: params, headers: httpHeader, timeout: 15, encode: nil, onSuccess: { (data) in
  // Success
, { (error) in
  // Fail and errors 
})

