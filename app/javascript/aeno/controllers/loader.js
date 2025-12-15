// Copied from @hotwired/stimulus-loading
function parseImportmapJson() {
  return JSON.parse(document.querySelector("script[type=importmap]").text)
    .imports;
}

function registerControllerFromPath(path, under, application) {
  // Build Stimulus identifier from import path
  // Extract namespace from the path (e.g., "aeno" from "aeno/components", "sqema" from "sqema/controllers")
  const namespace = under.split("/")[0];
  const pathType = under.split("/")[1]; // "components" or "controllers"

  const withoutPrefix = path.replace(new RegExp(`^${under}/`), "");

  let base;
  if (pathType === "components") {
    // Components: drop the last path segment ("controller" or "*_controller")
    // - "aeno/components/button/controller" -> "aeno/button" -> "aeno--button"
    // - "sqema/components/views/static/index/controller" -> "sqema/views/static/index" -> "sqema--views--static--index"
    if (withoutPrefix.endsWith("/controller")) {
      base = namespace + "/" + withoutPrefix.slice(0, -"/controller".length);
    } else if (/\/[^/]+_controller$/.test(withoutPrefix)) {
      base = namespace + "/" + withoutPrefix.replace(/\/[^/]+_controller$/, "");
    } else if (/_controller$/.test(withoutPrefix)) {
      // Fallback for flat files
      base = namespace + "/" + withoutPrefix.replace(/_controller$/, "");
    } else {
      // Not a controller path we recognize
      return;
    }
  } else if (pathType === "controllers") {
    // Standard controllers: namespace--(controllername)
    // - "sqema/controllers/hello_controller" -> "sqema/hello" -> "sqema--hello"
    base = namespace + "/" + withoutPrefix.replace(/_controller$/, "");
  } else {
    return;
  }

  const name = base.replace(/\//g, "--").replace(/_/g, "-");
  import(path)
    .then((module) => {
      if (module.default) {
        application.register(name, module.default);
      }
    })
    .catch((error) => {
      console.error(`Failed to register controller: ${name} (${path})`, error);
    });
}

function eagerLoadEngineControllersFrom(under, application) {
  const paths = Object.keys(parseImportmapJson()).filter((path) =>
    path.match(new RegExp(`^${under}/.+`)),
  );
  paths.forEach((path) => {
    if (path.endsWith("_controller") || path.endsWith("/controller")) {
      registerControllerFromPath(path, under, application);
    }
  });
}

export { eagerLoadEngineControllersFrom };
