import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var detectionFrame: UIView!
    var detectedCodeLabel: UILabel!
    var onCodeScanned: ((String) -> Void)? // Callback na zeskanowany kod

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // Konfiguracja sesji przechwytywania
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            fatalError("Brak dostępu do kamery")
        }

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            fatalError("Nie można skonfigurować wejścia kamery")
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            fatalError("Nie można dodać wejścia")
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                .ean8,
                .ean13,
                .upce,
                .code39,
                .code39Mod43,
                .code93,
                .code128,
                .pdf417,
                .aztec,
                .qr,
                .dataMatrix,
                .interleaved2of5,
                .itf14
            ]
        } else {
            fatalError("Nie można dodać wyjścia")
        }

        // Dodanie podglądu kamery
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Dodanie ramki wykrywania wstępnie ustawionej na środek
        detectionFrame = UIView()
        detectionFrame.layer.borderColor = UIColor.red.cgColor
        detectionFrame.layer.borderWidth = 2
        detectionFrame.frame = CGRect(
            x: view.frame.midX - 150,
            y: view.frame.midY - 50,
            width: 300,
            height: 100
        )
        view.addSubview(detectionFrame)

        // Dodanie etykiety do wyświetlania kodu
        detectedCodeLabel = UILabel()
        detectedCodeLabel.textAlignment = .center
        detectedCodeLabel.textColor = .white
        detectedCodeLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        detectedCodeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        detectedCodeLabel.isHidden = true
        detectedCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detectedCodeLabel)

        NSLayoutConstraint.activate([
            detectedCodeLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            detectedCodeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detectedCodeLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.9),
            detectedCodeLabel.heightAnchor.constraint(equalToConstant: 50)
        ])

        captureSession.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first else { return }
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
        guard let stringValue = readableObject.stringValue else { return }

        // Aktualizacja ramki
        if let transformedObject = previewLayer.transformedMetadataObject(for: readableObject) {
            detectionFrame.frame = transformedObject.bounds
            detectionFrame.layer.borderColor = UIColor.green.cgColor // Zmiana koloru ramki na zielony
        }

        // Wywołanie callbacka
        onCodeScanned?(stringValue)

        // Zatrzymanie sesji
        captureSession.stopRunning()
    }
}
