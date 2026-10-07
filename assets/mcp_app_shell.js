// flutter_mcp_app shell: runs inside an MCP Apps host and starts a Flutter web
// build in the host's own frame.
//
// The MCP resource only needs to load this script from the Flutter build:
//
//   <script src="https://your.app/assets/packages/flutter_mcp_app/assets/mcp_app_shell.js"
//           data-height="560"></script>
//
// Optional attributes:
//   data-height         view height in px (default 560)
//   data-app-url        Flutter build base URL (default: derived from this script's URL)
//   data-bootstrap-url  flutter_bootstrap.js URL (default: <app-url>flutter_bootstrap.js)
//   data-start          "input" (default: start on the tool input) or "result"
//                       (wait for the tool result, when the view needs it)
//
// The app talks to the host through window.mcpAppShell: post(message) for
// one-way messages and request(method, params) for JSON-RPC requests. Only the
// methods in APP_METHODS are relayed.
//
// Flutter's loader runs inside this frame, so the host must allow the build's
// origin in resourceDomains and connectDomains, and its script-src must allow
// WebAssembly. Claude does all three.
(function () {
  "use strict";

  var script = document.currentScript;
  var data = (script && script.dataset) || {};
  var HEIGHT = Number(data.height) || 560;
  var APP_URL = withSlash(data.appUrl || new URL("../../../../", script.src).href);
  var APP_ORIGIN = new URL(APP_URL).origin;
  var BOOTSTRAP_URL = data.bootstrapUrl || APP_URL + "flutter_bootstrap.js";
  var START_ON = data.start === "result" ? "result" : "input";
  var APP_METHODS = ["tools/call", "ui/message", "ui/open-link", "ui/update-model-context", "resources/read"];
  var START_TIMEOUT_MS = 25000;
  var LOG = "[mcp-app]";

  var nextId = 1;
  var pending = new Map();
  var started = false;
  var reported = false;
  var launch = { arguments: null, result: null };

  var style = document.createElement("style");
  style.textContent =
    "html,body{margin:0;padding:0;background:transparent}" +
    "#mcp-app-status{font:14px system-ui,sans-serif;opacity:.75;padding:16px}" +
    "#mcp-app-host{position:relative;width:100%;height:" + HEIGHT + "px;display:none}";
  document.head.appendChild(style);

  var status = document.createElement("div");
  status.id = "mcp-app-status";
  status.textContent = "Loading…";
  var host = document.createElement("div");
  host.id = "mcp-app-host";
  var root = document.body || document.documentElement;
  root.appendChild(status);
  root.appendChild(host);

  function withSlash(url) {
    return url.endsWith("/") ? url : url + "/";
  }

  function setStatus(text) {
    if (status.isConnected) status.textContent = text;
  }

  function send(message) {
    window.parent.postMessage(Object.assign({ jsonrpc: "2.0" }, message), "*");
  }

  function request(method, params) {
    var id = nextId++;
    send({ id: id, method: method, params: params });
    return new Promise(function (resolve, reject) {
      pending.set(id, { resolve: resolve, reject: reject });
    });
  }

  function notify(method, params) {
    send({ method: method, params: params });
  }

  function relayRequest(method, params) {
    if (APP_METHODS.indexOf(method) < 0) {
      return Promise.reject({ code: -32601, message: "Not relayed by the shell: " + method });
    }
    return request(method, params);
  }

  function reportSize(height) {
    notify("ui/notifications/size-changed", {
      width: document.documentElement.clientWidth,
      height: height,
    });
  }

  function start() {
    if (started) return;
    started = true;
    console.info(LOG, "starting", launch);
    setStatus("Starting…");
    host.style.display = "block";
    window.mcpAppShell = {
      arguments: launch.arguments,
      result: launch.result,
      appUrl: APP_URL,
      // Never rejects: resolves to {result} or {error}, so the app needn't
      // inspect raw JS exceptions.
      request: function (method, params) {
        return relayRequest(method, params).then(function (result) {
          return { result: result };
        }, function (error) {
          return { error: error || {} };
        });
      },
      flutterConfig: {
        entrypointBaseUrl: APP_URL,
        assetBase: APP_URL,
        canvasKitBaseUrl: APP_URL + "canvaskit/",
        hostElement: host,
      },
      post: onAppMessage,
    };
    reportSize(HEIGHT);
    var bootstrap = document.createElement("script");
    bootstrap.src = BOOTSTRAP_URL;
    bootstrap.onerror = function () {
      setStatus("Couldn't load the app from " + APP_ORIGIN + ".");
    };
    document.head.appendChild(bootstrap);
    setTimeout(function () {
      if (reported) return;
      setStatus("The app didn't start (origin: " + window.origin + ").");
      console.warn(LOG, "app never reported in");
    }, START_TIMEOUT_MS);
  }

  function onAppMessage(message) {
    if (!message || typeof message !== "object") return;
    if (!reported) {
      reported = true;
      status.remove();
      console.info(LOG, "app reported in");
    }
    if (message.type === "mcp-app:height") {
      host.style.height = message.height + "px";
      reportSize(message.height);
    } else if (message.type === "mcp-app:open-link") {
      request("ui/open-link", { url: message.url }).catch(function () {});
    }
  }

  function onHostMessage(data) {
    if (data.method === undefined && pending.has(data.id)) {
      var entry = pending.get(data.id);
      pending.delete(data.id);
      data.error ? entry.reject(data.error) : entry.resolve(data.result);
      return;
    }
    var params = data.params || {};
    if (data.method === "ui/notifications/tool-input") {
      launch.arguments = params.arguments || {};
      if (window.mcpAppShell) window.mcpAppShell.arguments = launch.arguments;
      if (START_ON === "input") start();
    } else if (data.method === "ui/notifications/tool-result") {
      launch.result = params.structuredContent || null;
      if (window.mcpAppShell) window.mcpAppShell.result = launch.result;
      start();
    } else if ((data.method === "ui/resource-teardown" || data.method === "ping") &&
        data.id !== undefined) {
      send({ id: data.id, result: {} });
    }
  }

  window.addEventListener("message", function (event) {
    var data = event.data;
    if (event.source !== window.parent || !data || typeof data !== "object") return;
    if (data.jsonrpc === "2.0") onHostMessage(data);
  });

  console.info(LOG, "shell origin:", window.origin, "app:", APP_URL);
  request("ui/initialize", {
    protocolVersion: "2026-01-26",
    appInfo: { name: "flutter_mcp_app", version: "0.1.0" },
    clientInfo: { name: "flutter_mcp_app", version: "0.1.0" },
    appCapabilities: { availableDisplayModes: ["inline"] },
  }).then(function (init) {
    console.info(LOG, "host:", init && init.hostInfo);
    notify("ui/notifications/initialized", {});
  });
})();
