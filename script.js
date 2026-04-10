const sampleNetworks = [
  { name: "HOME-WiFi-5G", signal: 4, security: "WPA3", channel: "36", mac: "A4:12:F3:8B:2C:1E", frequency: "5GHz" },
  { name: "TP-LINK_8842", signal: 3, security: "WPA2", channel: "11", mac: "C8:3A:35:2D:9F:44", frequency: "2.4GHz" },
  { name: "Guest_Network", signal: 2, security: "Open", channel: "6", mac: "5C:E9:1E:7A:B3:29", frequency: "2.4GHz" },
  { name: "NETGEAR47", signal: 4, security: "WPA2", channel: "1", mac: "2C:30:33:A1:F8:5D", frequency: "2.4GHz" },
  { name: "Office_Secure", signal: 3, security: "WPA2-Enterprise", channel: "48", mac: "F4:92:BF:3C:6E:A2", frequency: "5GHz" },
  { name: "Android_Hotspot", signal: 2, security: "WPA2", channel: "9", mac: "8A:7F:2E:B4:5C:33", frequency: "2.4GHz" },
  { name: "Linksys_Home", signal: 3, security: "WPA2", channel: "3", mac: "6E:4B:90:1A:C7:F2", frequency: "2.4GHz" },
  { name: "Public_WiFi", signal: 1, security: "Open", channel: "6", mac: "3D:8C:22:5F:B1:9A", frequency: "2.4GHz" }
];

let isScanning = false;

function startScan() {
  if (isScanning) return;
  
  isScanning = true;
  
  const scanButton = document.getElementById('scanButton');
  const buttonText = document.getElementById('buttonText');
  const statusBadge = document.getElementById('statusBadge');
  const scannerIcon = document.getElementById('scannerIcon');
  const scannerText = document.getElementById('scannerText');
  const scannerSubtext = document.getElementById('scannerSubtext');
  const networksSection = document.getElementById('networksSection');
  
  scanButton.disabled = true;
  buttonText.innerHTML = 'Scanning<span class="loading"></span>';
  statusBadge.textContent = 'Scanning...';
  statusBadge.classList.add('active');
  scannerIcon.classList.add('scanning');
  scannerText.textContent = 'Scanning for Networks';
  scannerSubtext.textContent = 'Please wait while we detect nearby WiFi networks';
  
  networksSection.classList.remove('show');
  document.getElementById('networkList').innerHTML = '';
  
  document.getElementById('networksFound').textContent = '0';
  document.getElementById('secureNetworks').textContent = '0';
  document.getElementById('openNetworks').textContent = '0';
  
  setTimeout(() => {
    displayResults();
  }, 3000);
}

function displayResults() {
  const scanButton = document.getElementById('scanButton');
  const buttonText = document.getElementById('buttonText');
  const statusBadge = document.getElementById('statusBadge');
  const scannerIcon = document.getElementById('scannerIcon');
  const scannerText = document.getElementById('scannerText');
  const scannerSubtext = document.getElementById('scannerSubtext');
  const networksSection = document.getElementById('networksSection');
  const networkList = document.getElementById('networkList');
  
  const numNetworks = Math.floor(Math.random() * 4) + 4;
  const shuffled = [...sampleNetworks].sort(() => 0.5 - Math.random());
  const selectedNetworks = shuffled.slice(0, numNetworks);
  
  const secureCount = selectedNetworks.filter(n => n.security !== 'Open').length;
  const openCount = selectedNetworks.filter(n => n.security === 'Open').length;
  
  scannerIcon.classList.remove('scanning');
  scannerText.textContent = 'Scan Complete';
  scannerSubtext.textContent = `Found ${selectedNetworks.length} networks in your area`;
  statusBadge.textContent = 'Complete';
  statusBadge.classList.remove('active');
  
  animateValue('networksFound', 0, selectedNetworks.length, 1000);
  animateValue('secureNetworks', 0, secureCount, 1000);
  animateValue('openNetworks', 0, openCount, 1000);
  
  selectedNetworks.forEach((network, index) => {
    setTimeout(() => {
      const networkHTML = createNetworkItem(network);
      networkList.innerHTML += networkHTML;
    }, index * 100);
  });
  
  setTimeout(() => {
    networksSection.classList.add('show');
  }, 200);
  
  setTimeout(() => {
    scanButton.disabled = false;
    buttonText.textContent = 'Scan Again';
    isScanning = false;
  }, 1000);
}

function createNetworkItem(network) {
  const signalBars = Array(4).fill('').map((_, i) => 
    `<div class="signal-bar ${i < network.signal ? 'active' : ''}"></div>`
  ).join('');
  
  let securityClass = 'secure';
  if (network.security === 'Open') {
    securityClass = 'open';
  } else if (network.security === 'WEP') {
    securityClass = 'medium';
  }
  
  const lockIcon = network.security === 'Open' ? '🔓' : '🔒';
  
  return `
    <div class="network-item">
      <div class="network-info">
        <div class="network-name">
          <span class="network-icon">${lockIcon}</span>
          ${network.name}
        </div>
        <div class="network-details">
          <span>MAC: ${network.mac}</span>
          <span>Channel: ${network.channel}</span>
          <span>${network.frequency}</span>
        </div>
      </div>
      <div class="network-meta">
        <div class="signal-indicator">${signalBars}</div>
        <div class="security-badge ${securityClass}">${network.security}</div>
      </div>
    </div>
  `;
}

function animateValue(id, start, end, duration) {
  const element = document.getElementById(id);
  const range = end - start;
  const increment = range / (duration / 16);
  let current = start;
  
  const timer = setInterval(() => {
    current += increment;
    if (current >= end) {
      current = end;
      clearInterval(timer);
    }
    element.textContent = Math.round(current);
  }, 16);
}

document.addEventListener('DOMContentLoaded', () => {
  console.log('WiFi Network Scanner Ready');
});