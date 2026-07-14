# Galeria

Galeria d'imatges i GIFs amb categorització per carpetes.

## Funcionalitats

- Galeria responsive amb grid de targetes
- Categories (carpetes = categories)
- Cerca per nom
- Lightbox amb navegació (fletxes, teclat ←→, swipe al mòbil)
- 4 botons per fitxer:
  - 💾 Descarrega l'arxiu
  - 🔗 Copia l'URL
  - 📋 Copia la imatge al clipboard (només imatges, no GIFs ni vídeos)
  - 🔄 Comparteix (Web Share API)
- Dark theme

## Ús

### Afegir contingut

1. Pengeu imatges/gifs a `pics/` o `gifs/` (subcarpetes = subcategories)
2. Executeu `./build.sh` per generar `gallery.json`
3. Feu `git push`
4. GitHub Actions desplega la web automàticament

### Tags

Editar `tags.txt` (generat per `build.sh`, conserva tags existents):

```
paco.gif: fail, humor
titanic.jpg: pel·lícula
```

### Categories

Les carpetes es converteixen en categories automàticament:

- `pics/` → categoria "pics"
- `pics/enigmarius/` → subcategoria "pics/enigmarius"
- `gifs/` → categoria "gifs"
- `gifs/Baste/` → subcategoria "gifs/Baste"

## Desenvolupament local

```bash
chmod +x build.sh
./build.sh
python3 -m http.server 8000
# Obre http://localhost:8000
```

## Stack

- HTML/CSS/JS (sense frameworks)
- Bash per build script
- GitHub Actions + Pages per desplegament

## Extensions suportades

| Tipus | Extensions |
|-------|-----------|
| Imatges | `.jpg`, `.jpeg`, `.png`, `.webp` |
| GIFs | `.gif` |
| Vídeos | `.mp4` |
