json.array!(@faqs)  do |faq|
  json.extract! faq, :id, :sortcode, :title, :detail, :lang
end
