import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import Admin1 from './admin1.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <Admin1 />
  </StrictMode>,
)
