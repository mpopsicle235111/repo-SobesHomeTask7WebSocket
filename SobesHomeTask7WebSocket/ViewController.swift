//
//  ViewController.swift
//  SobesHomeTask7WebSocket
//
//  Created by Anton Lebedev on 02.05.2023.
//  As per iOS Academy video
//  "Swift: WebSocket Real-Time Data Introduction"
//  https://youtu.be/VwzXiJgsDrE

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {

    private var webSocket: URLSessionWebSocketTask?
    
    private let closeConnectionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Close connection", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBlue
        
        // MARK: - Create a WebSocket
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()  // Let's reserve .main for interface
        )
        // This is the URL which sends and receives requests
        // Sockets use WSS protocol i/o HTTPS
        let url = URL(string: "wss://polkadot.webapi.subscan.io/socket")
        webSocket = session.webSocketTask(with: url!)
        webSocket?.resume()  // Actually send the request
        
        // Display a button to close connection
        closeConnectionButton.frame = CGRect(x: 0, y: 0, width: 250, height: 50)
        closeConnectionButton.center = view.center
        view.addSubview(closeConnectionButton)
        closeConnectionButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }

    // MARK: - 4 main functions
    // We need to ping a WebSocket to establish connection
    // and later check if the connection is still alive
    func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        }
    }
    // This is how we close connection
    // @objc added, because we connect this func to a closeConnectionButton via selector
    @objc func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    
    // Send data. For this example - just some random Integer
    // We also repeat this on back Queue every one second
    func send() {
        DispatchQueue.global().asyncAfter(deadline: .now()+1) {
            self.send()  // We continuosly send requests
            self.webSocket?.send(.string("Send new message: \(Int.random(in: 0...1000))"), completionHandler: { error in
                if let error = error {
                    print("\"Send\" function error: \(error)")
                }
            })
        }
    }
    
    // Receive data
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):  //We can receive Data, String or something else
                switch message {
                case .data(let data):
                    print("Got Data: \(data)")
                case .string(let message):
                    print("Got string: \(message)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("\"Receive\" function error: \(error)")
            }
            self?.receive()  // We constantly want to receive data again and again
                             // so we use [weak self] above to avoid a memory leak
        })
    }
    
    // MARK: - 2 functions to conform to URLSessionWebSocketDelegate
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        ping()
        receive()
        send()
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection with reason")
    }

}

