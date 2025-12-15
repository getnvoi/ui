import { application } from "aeno/controllers/application";
import { eagerLoadEngineControllersFrom } from "aeno/controllers/loader";

// Load component controllers
eagerLoadEngineControllersFrom("aeno/components", application);
