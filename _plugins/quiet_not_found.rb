# `jekyll serve` logs every request for a missing page as an ERROR, even though it's
# answered by the 404 page as intended; answer those without the log line
module Jekyll
  module QuietNotFound
    def service(req, res)
      super
    rescue WEBrick::HTTPStatus::NotFound => e
      res.set_error(e)
    end
  end
end

Jekyll::Hooks.register :site, :after_init do |site|
  next unless site.config["serving"]

  require "webrick"
  WEBrick::HTTPServer.prepend(Jekyll::QuietNotFound) unless WEBrick::HTTPServer < Jekyll::QuietNotFound
end
