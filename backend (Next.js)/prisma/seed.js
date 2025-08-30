const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    console.log('Starting seed...');

    // Création de 5 projets d'exemple
    await prisma.project.createMany({
        data: [
            {
                name: "Residence A",
                status: "PUBLISHED",
                amount: 120000,
                createdAt: new Date("2024-01-10T10:00:00Z")
            },
            {
                name: "Loft B",
                status: "DRAFT",
                amount: 85000,
                createdAt: new Date("2024-02-05T12:30:00Z")
            },
            {
                name: "Villa C",
                status: "ARCHIVED",
                amount: 240000,
                createdAt: new Date("2023-11-20T09:15:00Z")
            },
            {
                name: "Immeuble D",
                status: "PUBLISHED",
                amount: 410000,
                createdAt: new Date("2024-03-01T08:00:00Z")
            },
            {
                name: "Studio E",
                status: "DRAFT",
                amount: 60000,
                createdAt: new Date("2024-04-18T14:45:00Z")
            }
        ],
        skipDuplicates: true // Évite les doublons si le script est exécuté plusieurs fois
    });

    console.log("Seed finished successfully.");
}

// Gestion des erreurs et fermeture de la connexion
main()
    .catch(e => {
        console.error('Seed failed:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });