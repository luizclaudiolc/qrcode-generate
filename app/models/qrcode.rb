class Qrcode < ApplicationRecord
  has_one_attached :image

  before_create :qrcode_genarate

  private

  def qrcode_genarate
    qr_code = RQRCode::QRCode.new(url)
    qr_png = qr_code.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 600
    )

    image_name = SecureRandom.hex
    path = "tmp/storage/#{image_name}.png"

    IO.binwrite(path, qr_png.to_s)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(path),
      filename: image_name,
      content_type: 'png'
    )

    image.attach(blob)
  end
end
