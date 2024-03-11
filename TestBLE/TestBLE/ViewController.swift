//
//  ViewController.swift
//  TestBLE
//
//  Created by rendi on 10.03.2024.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    var peripheral: CBPeripheral!

    let ctsServiceUUID = CBUUID(string: "00001805-0000-1000-8000-00805f9b34fb") // Current Time Service UUID
    let currentTimeCharacteristicUUID = CBUUID(string: "00002a2b-0000-1000-8000-00805f9b34fb") // Current Time Characteristic UUID
    let devicePrefix = "SOME_DEVICE_PREFIX";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    @IBAction func startScanAction(_ sender: UIButton) {
        self.startScanning(with: centralManager)
    }
    
    @IBAction func stopScanAction(_ sender: UIButton) {
        self.stopScanning(with: centralManager)
    }
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            print("No services found")
            return
        }
        
        for service in services {
            print("Discovered service: \(service)")
            // Do something with the discovered service if needed
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Central: Bluetooth is powered on.")
            startScanning(with: central)
        } else {
            print("Central: Bluetooth is not available.")
        }
    }
    
    func startScanning(with central: CBCentralManager) {
        central.scanForPeripherals(withServices: nil, options: nil)
        print("Central: Scanning started")
    }
    
    func stopScanning(with central: CBCentralManager) {
        central.stopScan()
        print("Central: Scanning stopped")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print(peripheral.name)
        guard peripheral.name?.hasPrefix(devicePrefix) == true else {
            return
        }

        print("Central: Discovered peripheral: \(peripheral)")
        self.peripheral = peripheral
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Central: Connected to peripheral: \(peripheral)")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Central: Disconnected from peripheral: \(peripheral)")
        // Handle disconnection
    }
}


// MARK: - CBPeripheralManagerDelegate
extension ViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("Peripheral: Bluetooth is powered on.")
            setupCustomCTS()
        } else {
            print("Peripheral: Bluetooth is not available.")
        }
    }

    func setupCustomCTS() {
        print("setupCustomCTS")
        
        // Create your custom characteristic with the same UUID as the default CTS
        let currentTimeCharacteristic = CBMutableCharacteristic(type: currentTimeCharacteristicUUID,
                                                                 properties: [.read, .notify],
                                                                 value: nil,
                                                                 permissions: [.readable])
        
        // Create your custom service with the same UUID as the default CTS
        let ctsService = CBMutableService(type: ctsServiceUUID, primary: true)
        ctsService.characteristics = [currentTimeCharacteristic]
        
        // Add your custom service to the peripheral manager
        peripheralManager.add(ctsService)
    }
    
    // Handle read requests for your custom characteristic
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("[peripheralManager] request \(request.characteristic.uuid)");
        // Check if the requested characteristic UUID matches your custom CTS characteristic UUID
        if request.characteristic.uuid == currentTimeCharacteristicUUID {
            // Respond with the desired data for your custom characteristic
            let bytes: [UInt8] = [0xC2, 0x07, 0x0B, 0x0F, 0x0D, 0x25, 0x2A, 0x06, 0xFE, 0x08]
            request.value = Data(bytes)
            
            // Respond to the read request
            peripheral.respond(to: request, withResult: .success)
        } else {
            // For other characteristics, respond as needed
            peripheral.respond(to: request, withResult: .attributeNotFound)
        }
    }
}
