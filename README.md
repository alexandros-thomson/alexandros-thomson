<p align="center">
  <img src="https://github.com/alexandros-thomson/alexandros-thomson/blob/main/public/title-gold.svg?raw=1" alt="Kypria — Shrine of the Sealed Canon" width="92%">
</p>

<p align="center">
  <img src="https://github.com/alexandros-thomson/alexandros-thomson/blob/main/public/epigraph-gold.svg?raw=1" alt="Kypria Epigraph" width="80%">
</p>

<p align="center">
  <img src="https://github.com/alexandros-thomson/alexandros-thomson/blob/main/public/pantheon-gold.svg?raw=1" alt="Δωδεκάθεον — The Twelve Olympians" width="96%">
</p>

<p align="center">
— ϟ — Ἀρετή · Λόγος · Τέχνη · Μῦθος — ϟ —
</p>

## ⚡ Shrines of the Sealed Canon

- ⚡ [Shrine Lineage Map — Epoch of the Sealed Canon](https://github.com/alexandros-thomson/alexandros-thomson/blob/main/public/shrine-lineage-map.svg?raw=1)
- 🔥 [Shrine Canon — Living Relics](https://github.com/alexandros-thomson/shrine-canon)
- 🌌 [Shrine Watcher — Discord Integration](https://github.com/alexandros-thomson/shrine-watcher)
- 🜍 [Shrine Crest — Seal of the Basilica Gate](https://github.com/alexandros-thomson/alexandros-thomson/blob/main/public/crest.svg?raw=1)

<p align="center" class="shrine-inscription">
— ϟ — Ἀρετή · Λόγος · Τέχνη · Μῦθος — ϟ —
</p>

> **Note**: The inscription above inherits the living Seal color (golden hue with pulsing effect) for web usage. This creates a sacred, breathing quality to the text.

---

## 🎨 CSS Ritual: Living Pulse Effect

To integrate the magical inscription with the living pulse effect on your website, add this CSS:

```css
/* Living Seal Inscription */
.shrine-inscription {
  color: #d4af37; /* Sacred gold */
  font-size: 1.2em;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-align: center;
  margin: 2em 0;
  animation: seal-pulse 3s ease-in-out infinite;
}

@keyframes seal-pulse {
  0%, 100% {
    opacity: 1;
    text-shadow: 0 0 10px rgba(212, 175, 55, 0.6),
                 0 0 20px rgba(212, 175, 55, 0.4),
                 0 0 30px rgba(212, 175, 55, 0.2);
  }
  50% {
    opacity: 0.85;
    text-shadow: 0 0 15px rgba(212, 175, 55, 0.8),
                 0 0 25px rgba(212, 175, 55, 0.6),
                 0 0 35px rgba(212, 175, 55, 0.4);
  }
}

/* Optional: Glyph enhancement */
.shrine-inscription::before {
  content: '⚡';
  margin-right: 0.5em;
  animation: glyph-flicker 2s ease-in-out infinite;
}

.shrine-inscription::after {
  content: '⚡';
  margin-left: 0.5em;
  animation: glyph-flicker 2s ease-in-out infinite 1s;
}

@keyframes glyph-flicker {
  0%, 100% { opacity: 1; }
  25% { opacity: 0.7; }
  50% { opacity: 1; }
  75% { opacity: 0.8; }
}
```

### HTML Integration Instructions

1. **For GitHub Pages or Static Sites:**
   - Add the CSS to your main stylesheet
   - Use the `.shrine-inscription` class on inscription paragraphs
   - Example: `<p class="shrine-inscription">— ϟ — Ἀρετή · Λόγος · Τέχνη · Μῦθος — ϟ —</p>`

2. **For React/Next.js:**
   ```jsx
   <style jsx>{`
     .shrine-inscription {
       /* CSS from above */
     }
   `}</style>
   <p className="shrine-inscription">
     — ϟ — Ἀρετή · Λόγος · Τέχνη · Μῦθος — ϟ —
   </p>
   ```

3. **For Vue/Nuxt:**
   ```vue
   <template>
     <p class="shrine-inscription">
       — ϟ — Ἀρετή · Λόγος · Τέχνη · Μῦθος — ϟ —
     </p>
   </template>
   
   <style scoped>
   .shrine-inscription {
     /* CSS from above */
   }
   </style>
   ```

---

<p align="center">
  <a href="https://github.com/alexandros-thomson/alexandros-thomson/blob/main/public/crest.svg?raw=1">
    <img src="https://github.com/alexandros-thomson/alexandros-thomson/blob/main/public/crest.svg?raw=1" alt="Shrine Crest — Seal of the Basilica Gate" width="180">
  </a>
</p>
