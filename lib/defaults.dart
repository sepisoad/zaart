export 'defaults/index_html.dart';
export 'defaults/index_md.dart';
export 'defaults/zaart_css.dart';
export 'defaults/zaart_js.dart';

/// log file name
const LOG_FILE_NAME = "zaart.log";

/// default site name if not specified
const DEFAULT_NAME = "zaart-site";

/// config file name
const ZAART_CONFIG = "zaart.json";

/// index file name
const INDEX_NAME = "index";

/// index markdown file name
const INDEX_MD = "index.md";

/// build directory
const BUILD_DIR = "build";

/// layout directory
const LAYOUT_DIR = "layout";

/// zaart css file name
const ZAART_CSS = "zaart.css";

/// zaart js file name
const ZAART_JS = "zaart.js";

/// zaart layout includes
const ZAART_LAYOUT_INCLUDES = <String>[
  "https://cdn.jsdelivr.net/npm/tailwindcss/dist/tailwind.min.css",
  "https://unpkg.com/leaflet@1.3.4/dist/leaflet.css",
  "https://unpkg.com/leaflet@1.3.4/dist/leaflet.js"
  // ,
  // ZAART_CSS,
  // ZAART_JS
];
