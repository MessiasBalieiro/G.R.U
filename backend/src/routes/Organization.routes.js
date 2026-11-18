import { Router } from "express";
import organizationController from "../Controllers/Organization.controller.js";
import userMiddleware from "../Middlewares/User.middleware.js";

const router = Router();

router.get("/all-orgs", organizationController.getAllOrganizations);

router.get("/this-org", userMiddleware.validateRoleAdmin("CONTRATANTE"), organizationController.getThisOrganization);

router.get("/this-org-id", userMiddleware.validateRoleAdmin("CONTRATANTE"), organizationController.getThisOrganizationById);

router.post("/create-org", userMiddleware.validateRoleAdmin("CONTRATANTE"), organizationController.createOrganization);

router.post("/add-trash", userMiddleware.validateRoleAdmin("ADMINISTRADOR"), organizationController.addTrashToOrganization);

router.post("/remove-trash", userMiddleware.validateRoleAdmin("ADMINISTRADOR"), organizationController.removeTrashFromOrganization);

router.post("/add-colector", userMiddleware.validateRoleAdmin("CONTRATANTE"), organizationController.addColectorToOrganization);

router.post("/remove-colector", userMiddleware.validateRoleAdmin("CONTRATANTE"), organizationController.removeColectorFromOrganization);

export default router;