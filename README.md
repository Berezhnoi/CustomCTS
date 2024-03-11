# Custom Current Time Service (CTS) Implementation for Bluetooth Low Energy (BLE) Device

This project is a proof of concept (POC) implementation for creating a custom Current Time Service (CTS) for a Bluetooth Low Energy (BLE) device. The custom CTS is implemented using CoreBluetooth framework on iOS platform.

## Overview

The goal of this project is to demonstrate how to create a custom CTS on an iOS device acting as a BLE peripheral. By default, iOS devices advertise a standard CTS with a predefined service UUID and characteristic UUID.

## Requirements

- iOS device running iOS 7.0 or later
- Xcode 12.0 or later

## Implementation Details

The custom CTS implementation involves the following steps:

1. Creating a custom CTS service with the same UUID as the default CTS.

2. Adding a custom characteristic to the custom CTS service.

3. Handling read requests for the custom characteristic to provide the desired data.

All code for testing the custom CTS implementation is located in the `ViewController.swift` file. Please open `ViewController.swift` to view the implementation details.
