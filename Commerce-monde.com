{
  "name": "mon-annuaire",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "14.0.4",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "axios": "^1.6.2",
    "mongoose": "^8.0.3"
  }
}import { useState, useEffect } from 'react';
import Link from 'next/link';
import Layout from '../components/Layout';
import SearchBar from '../components/SearchBar';
import CommerceCard from '../components/CommerceCard';

export default function Home() {
  const [commerces, setCommerces] = useState([]);
  const [filtered, setFiltered] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchCommerces();
  }, []);

  const fetchCommerces = async () => {
    try {
      const res = await fetch('/api/commerces');
      const data = await res.json();
      setCommerces(data);
      setFiltered(data);
      setLoading(false);
    } catch (error) {
      console.error('Erreur:', error);
      setLoading(false);
    }
  };

  const handleSearch = (query) => {
    if (!query.trim()) {
      setFiltered(commerces);
      return;
    }
    const results = commerces.filter(c => 
      c.nom.toLowerCase().includes(query.toLowerCase()) ||
      c.ville.toLowerCase().includes(query.toLowerCase()) ||
      c.pays.toLowerCase().includes(query.toLowerCase())
    );
    setFiltered(results);
  };

  return (
    <Layout>
      {/* HERO SECTION */}
      <section className="hero">
        <div className="container">
          <h1>🌍 Découvrez les meilleurs commerçants du monde</h1>
          <p>Restaurants, boutiques, artisans... Trouvez en 2 clics, où que vous soyez</p>
          <SearchBar onSearch={handleSearch} />
          <Link href="/ajouter" className="btn-primary">
            📢 Ajouter mon commerce gratuitement
          </Link>
        </div>
      </section>

      {/* STATS */}
      <section className="stats">
        <div className="container">
          <div className="stats-grid">
            <div className="stat-item">
              <span className="stat-number">50+</span>
              <span className="stat-label">Pays représentés</span>
            </div>
            <div className="stat-item">
              <span className="stat-number">{commerces.length}</span>
              <span className="stat-label">Commerçants inscrits</span>
            </div>
            <div className="stat-item">
              <span className="stat-number">1000+</span>
              <span className="stat-label">Visiteurs par mois</span>
            </div>
          </div>
        </div>
      </section>

      {/* COMMERCES LIST */}
      <section className="commerces">
        <div className="container">
          <h2>🏪 Nos commerçants à la une</h2>
          {loading ? (
            <p>Chargement...</p>
          ) : (
            <div className="commerce-grid">
              {filtered.length > 0 ? (
                filtered.map(commerce => (
                  <CommerceCard key={commerce.id} commerce={commerce} />
                ))
              ) : (
                <p>Aucun commerce trouvé</p>
              )}
            </div>
          )}
        </div>
      </section>

      {/* CTA */}
      <section className="cta">
        <div className="container">
          <h2>Votre commerce n'est pas répertorié ?</h2>
          <Link href="/ajouter" className="btn-primary btn-large">
            Ajouter mon commerce gratuitement
          </Link>
        </div>
      </section>

      <style jsx>{`
        .hero {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 80px 20px;
          text-align: center;
        }
        .hero h1 {
          font-size: 48px;
          margin-bottom: 20px;
        }
        .hero p {
          font-size: 20px;
          margin-bottom: 30px;
          opacity: 0.9;
        }
        .container {
          max-width: 1200px;
          margin: 0 auto;
          padding: 0 20px;
        }
        .btn-primary {
          background: white;
          color: #667eea;
          padding: 15px 30px;
          border-radius: 50px;
          font-weight: bold;
          text-decoration: none;
          display: inline-block;
          margin-top: 20px;
        }
        .btn-large {
          padding: 20px 50px;
          font-size: 18px;
        }
        .stats {
          background: #f8f9fa;
          padding: 60px 20px;
        }
        .stats-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
          gap: 30px;
          text-align: center;
        }
        .stat-number {
          font-size: 48px;
          font-weight: bold;
          color: #667eea;
          display: block;
        }
        .stat-label {
          font-size: 18px;
          color: #666;
        }
        .commerces {
          padding: 60px 20px;
        }
        .commerces h2 {
          text-align: center;
          margin-bottom: 40px;
          font-size: 36px;
        }
        .commerce-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
          gap: 30px;
        }
        .cta {
          background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
          color: white;
          padding: 80px 20px;
          text-align: center;
        }
        .cta h2 {
          font-size: 36px;
          margin-bottom: 30px;
        }
        @media (max-width: 768px) {
          .hero h1 { font-size: 32px; }
          .stat-number { font-size: 32px; }
        }
      `}</style>
    </Layout>
  );
}import { useState } from 'react';

export default function SearchBar({ onSearch }) {
  const [query, setQuery] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    onSearch(query);
  };

  return (
    <form onSubmit={handleSubmit} className="search-bar">
      <input
        type="text"
        placeholder="🔍 Rechercher un commerce (nom, ville, pays)..."
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />
      <button type="submit">Rechercher</button>
      <style jsx>{`
        .search-bar {
          display: flex;
          max-width: 600px;
          margin: 0 auto;
          gap: 10px;
        }
        .search-bar input {
          flex: 1;
          padding: 15px 20px;
          border: none;
          border-radius: 50px;
          font-size: 16px;
        }
        .search-bar button {
          padding: 15px 30px;
          background: #ff6b6b;
          color: white;
          border: none;
          border-radius: 50px;
          font-weight: bold;
          cursor: pointer;
        }
        @media (max-width: 600px) {
          .search-bar {
            flex-direction: column;
          }
        }
      `}</style>
    </form>import Link from 'next/link';

export default function CommerceCard({ commerce }) {
  return (
    <div className="card">
      {commerce.photo && (
        <img src={commerce.photo} alt={commerce.nom} className="card-image" />
      )}
      <div className="card-content">
        <h3>{commerce.nom}</h3>
        <p className="category">{commerce.categorie}</p>
        <p className="location">📍 {commerce.ville}, {commerce.pays}</p>
        <p className="description">{commerce.description?.substring(0, 100)}...</p>
        <Link href={`/commerces/${commerce.id}`} className="card-link">
          Voir la fiche →
        </Link>
      </div>
      <style jsx>{`
        .card {
          background: white;
          border-radius: 12px;
          overflow: hidden;
          box-shadow: 0 4px 6px rgba(0,0,0,0.1);
          transition: transform 0.3s;
        }
        .card:hover {
          transform: translateY(-5px);
        }
        .card-image {
          width: 100%;
          height: 200px;
          object-fit: cover;
        }
        .card-content {
          padding: 20px;
        }
        .card-content h3 {
          margin: 0 0 10px 0;
          font-size: 20px;
        }
        .category {
          color: #667eea;
          font-weight: bold;
          font-size: 14px;
          margin: 5px 0;
        }
        .location {
          color: #666;
          font-size: 14px;
          margin: 5px 0;
        }
        .description {
          color: #888;
          font-size: 14px;
          margin: 10px 0;
        }
        .card-link {
          display: inline-block;
          color: #667eea;
          font-weight: bold;
          text-decoration: none;
          margin-top: 10px;
        }
      `}</style>
    </div>import Link from 'next/link';

export default function Layout({ children }) {
  return (
    <div>
      <nav className="navbar">
        <div className="container">
          <Link href="/" className="logo">
            🌍 MonAnnuaire
          </Link>
          <div className="nav-links">
            <Link href="/">Accueil</Link>
            <Link href="/commerces">Commerces</Link>
            <Link href="/ajouter" className="nav-btn">Ajouter</Link>
          </div>
        </div>
      </nav>
      <main>{children}</main>
      <footer className="footer">
        <div className="container">
          <p>© 2026 MonAnnuaire - Tous droits réservés</p>
          <div className="footer-links">
            <Link href="/mentions-legales">Mentions légales</Link>
            <Link href="/contact">Contact</Link>
          </div>
        </div>
      </footer>
      <style jsx>{`
        .navbar {
          background: white;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          padding: 15px 0;
          position: sticky;
          top: 0;
          z-index: 100;
        }
        .navbar .container {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }
        .logo {
          font-size: 24px;
          font-weight: bold;
          color: #667eea;
          text-decoration: none;
        }
        .nav-links {
          display: flex;
          gap: 20px;
          align-items: center;
        }
        .nav-links a {
          text-decoration: none;
          color: #333;
        }
        .nav-btn {
          background: #667eea;
          color: white !important;
          padding: 10px 20px;
          border-radius: 50px;
          font-weight: bold;
        }
        .footer {
          background: #2d3436;
          color: white;
          padding: 30px 0;
          margin-top: 60px;
        }
        .footer .container {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }
        .footer-links {
          display: flex;
          gap: 20px;
        }
        .footer-links a {
          color: #ccc;
          text-decoration: none;
        }
        .container {
          max-width: 1200px;
          margin: 0 auto;
          padding: 0 20px;
        }
        @media (max-width: 768px) {
          .navbar .container {
            flex-direction: column;
            gap: 15px;
          }
          .footer .container {
            flex-direction: column;
            gap: 15px;
            text-align: center;
          }
        }
      `}</style>
    </div>
  );
}
  );
}
  );
}
