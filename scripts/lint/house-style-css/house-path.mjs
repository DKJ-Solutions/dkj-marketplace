// The stylesheets this gate reads: every .css in the dkj-policy plugin's assets/dkj-brandbook folder (#3493; renamed
// from house-style), and every .css in the dkj-solutions plugin's assets/dkj-brandbook-product folder, the product
// layer since the split (#3831). house-style.css is the token source; any other stylesheet in either folder is a
// layer on top of it and holds no colour code of its own. Read from the folders and every folder under them rather
// than named, so a stylesheet added later is gated without an edit here.
import { readdirSync } from 'node:fs'
import { join } from 'node:path'

export const repoRoot = join(import.meta.dirname, '..', '..', '..')
export const houseDir = join(repoRoot, 'plugins', 'dkj-policy', 'assets', 'dkj-brandbook')
export const productDir = join(repoRoot, 'plugins', 'dkj-policy', 'dkj-solutions', 'assets', 'dkj-brandbook-product')
export const houseCss = join(houseDir, 'house-style.css')
export const houseSheets = [houseDir, productDir]
  .flatMap((dir) => readdirSync(dir, { recursive: true })
    .filter((f) => f.endsWith('.css'))
    .map((f) => join(dir, f)))
  .sort()
