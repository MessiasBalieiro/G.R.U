import { Router } from 'express';
import userRoutes from './User.routes.js';
import trashRoutes from './Trash.routes.js';
import residueRoutes from './Residue.routes.js';
import organizationRoutes from './Organization.routes.js';
import cicloRoutes from './ciclo.route.js';

const router = Router();

router.get('/', (req, res) => {
    res.send('Olá, Mundo!');
    console.log('Olá, Mundo!');
})

export default (app) => {
    app.use(router);
    app.use('/users', userRoutes);
    app.use('/trashes', trashRoutes);
    app.use('/residues', residueRoutes);
    app.use('/organizations', organizationRoutes);
    app.use('/ciclo', cicloRoutes);
};