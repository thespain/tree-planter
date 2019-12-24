# frozen_string_literal: true

# config.ru (run with rackup)
require 'rack'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

require './tree_planter'

use Rack::Deflater
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

run TreePlanter
