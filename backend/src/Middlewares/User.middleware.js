class UserMiddleware {
    static validateRoleAdmin(role) {
        return (req, res, next) => {
            if(req.query.rl.toUpperCase() == role) {
                next()
            }
            else {
                res.status(403).send("Seu nível de acesso não permite prosseguir com essa ação!");
            }
        }
    }
}

export default UserMiddleware;