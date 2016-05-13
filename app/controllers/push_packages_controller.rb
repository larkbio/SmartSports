class PushPackagesController < ApplicationController
  def download
    send_file('lib/SmartAdverse.pushpackage.zip', type: 'application/zip')
  end

  def push
    puts params
    send_success_json(nil, ok: true)
  end

  def log
    puts params
    send_success_json(nil, ok: true)
  end

end
