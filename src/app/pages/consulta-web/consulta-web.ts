import { Component, ChangeDetectorRef, inject } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-consulta-web',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="consulta-container">
      <div class="glass-panel">
        <h1 class="title">Consulta de información</h1>
        
        <button class="btn-consultar" (click)="consultar()" [disabled]="loading">
          {{ loading ? 'Consultando...' : 'CONSULTAR' }}
        </button>

        <div class="status-area">
          <div *ngIf="loading" class="consulta-loader">Consultando...</div>
          <div *ngIf="error" class="error-msg">No fue posible obtener la información.</div>
          <div *ngIf="data && !loading && !error" class="data-display">
            <pre>{{ data | json }}</pre>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .consulta-container {
      min-height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      background: linear-gradient(135deg, #0f2027, #203a43, #2c5364);
      font-family: 'Inter', system-ui, sans-serif;
      padding: 20px;
    }
    .glass-panel {
      background: rgba(255, 255, 255, 0.05);
      backdrop-filter: blur(10px);
      -webkit-backdrop-filter: blur(10px);
      border-radius: 20px;
      border: 1px solid rgba(255, 255, 255, 0.1);
      padding: 40px;
      width: 100%;
      max-width: 500px;
      text-align: center;
      box-shadow: 0 15px 35px rgba(0,0,0,0.2);
    }
    .title {
      color: #fff;
      font-size: 24px;
      margin-bottom: 30px;
      text-transform: uppercase;
      letter-spacing: 2px;
      text-shadow: 0 0 10px rgba(255,255,255,0.3);
    }
    .btn-consultar {
      background: linear-gradient(45deg, #00d2ff, #3a7bd5);
      border: none;
      border-radius: 50px;
      padding: 15px 40px;
      color: white;
      font-size: 16px;
      font-weight: bold;
      letter-spacing: 1px;
      cursor: pointer;
      transition: all 0.3s ease;
      box-shadow: 0 0 15px rgba(0, 210, 255, 0.5);
    }
    .btn-consultar:hover:not([disabled]) {
      transform: translateY(-2px);
      box-shadow: 0 0 25px rgba(0, 210, 255, 0.8);
    }
    .btn-consultar[disabled] {
      opacity: 0.7;
      cursor: not-allowed;
    }
    .status-area {
      margin-top: 30px;
      min-height: 100px;
    }
    .consulta-loader {
      color: #00d2ff;
      font-size: 18px;
      animation: pulse 1.5s infinite;
      font-weight: 500;
    }
    .error-msg {
      color: #ff4b4b;
      background: rgba(255, 75, 75, 0.1);
      padding: 15px;
      border-radius: 10px;
      border: 1px solid rgba(255, 75, 75, 0.3);
      font-weight: 500;
    }
    .data-display {
      background: rgba(0, 0, 0, 0.3);
      padding: 20px;
      border-radius: 10px;
      color: #a8b2d1;
      text-align: left;
      overflow-x: auto;
      border: 1px solid rgba(255, 255, 255, 0.05);
      font-size: 14px;
    }
    pre {
      margin: 0;
      white-space: pre-wrap;
      word-wrap: break-word;
    }
    @keyframes pulse {
      0% { opacity: 0.6; }
      50% { opacity: 1; text-shadow: 0 0 10px #00d2ff; }
      100% { opacity: 0.6; }
    }
  `]
})
export class ConsultaWebComponent {
  private cdr = inject(ChangeDetectorRef);
  loading = false;
  error = false;
  data: any = null;
  
  // URL preasignada para la prueba (JSONPlaceholder API)
  readonly URL = 'https://jsonplaceholder.typicode.com/users/1';

  async consultar() {
    this.loading = true;
    this.error = false;
    this.data = null;
    this.cdr.detectChanges();
    
    try {
      // Pequeña demora para hacer visible el estado "Consultando..."
      await new Promise(resolve => setTimeout(resolve, 800));
      
      const response = await fetch(this.URL);
      if (!response.ok) {
        throw new Error('HTTP Error');
      }
      
      const jsonData = await response.json();
      this.data = jsonData;
    } catch (e) {
      this.error = true;
    } finally {
      this.loading = false;
      this.cdr.detectChanges();
    }
  }
}
