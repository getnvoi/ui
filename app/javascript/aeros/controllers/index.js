import { application } from "aeros/controllers/application";
import { eagerLoadEngineControllersFrom } from "aeros/controllers/loader";

// Load component controllers
eagerLoadEngineControllersFrom("aeros/components", application);
