import Foundation
import Cocoa

class ImageWriter{
  struct Color {
    var Red:Double
    var Green:Double
    var Blue:Double
  }

  let width:Int
  let height:Int
  private let pictPath:URL
  var data:[[Color]]

  init(width:Int=500,height:Int=500) {
    self.width = width//横
    self.height = height//縦
    data = Array.init(repeating: Array.init(repeating: Color(Red: 0,Green: 0,Blue: 0), count: height), count: width)
    if let url = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).last{
      pictPath = url.appendingPathComponent("PathTracing.png")
    }else{
      fatalError("ピクチャフォルダが開けませんでした。")
    }
  }

  private func makeNSImage() -> NSImage
  {
    var imageBytes:UnsafeMutablePointer<UInt8>
    let ByteLength = width*height*4
    imageBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: ByteLength)

    for i in 0..<width{
      for j in 0..<height{
        let k = ((width*j)+i)*4
        let pix = data[i][j]
        data[i][j].Red = max(min(pix.Red, 1), 0)
        data[i][j].Green = max(min(pix.Green, 1), 0)
        data[i][j].Blue = max(min(pix.Blue, 1), 0)
        if pix.Red.isNaN||pix.Green.isNaN||pix.Blue.isNaN{
          data[i][j] = Color(Red: 0,Green: 0,Blue: 0)
        }
        imageBytes[k  ] = UInt8((data[i][j].Red*255).truncatingRemainder(dividingBy: 256))
        imageBytes[k+1] = UInt8((data[i][j].Green*255).truncatingRemainder(dividingBy: 256))
        imageBytes[k+2] = UInt8((data[i][j].Blue*255).truncatingRemainder(dividingBy: 256))
        imageBytes[k+3] = UInt8((1.0*255).truncatingRemainder(dividingBy: 256))
      }
    }
    let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
      return
    }
    let provider = CGDataProvider(dataInfo: nil, data: imageBytes, size: ByteLength, releaseData: releaseMaskImagePixelData)

    let bitsPerComponent:Int = 8
    let bitsPerPixcel:Int = bitsPerComponent*4
    let bytesPerRow = 4*width
    let cgImage = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixcel, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo:CGBitmapInfo.byteOrder32Big, provider: provider!, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)

    let size = NSSize(width: width, height: height)
    let img  = NSImage(cgImage: cgImage!, size: size)


    return img
  }

  func makeImage(){
    let src = makeNSImage()
    let tiff = src.tiffRepresentation
    let imgRep = NSBitmapImageRep(data: tiff!)
    let data = imgRep?.representation(using: .png, properties: [:])

    do {
      try data?.write(to: pictPath)
    } catch {
      Swift.print("\(error)")
      fatalError("画像を保存できませんでした。")
    }
    print("Image was saved to \(pictPath).")
  }
}
