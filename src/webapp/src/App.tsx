import React from 'react';
import { useAccount, useConnect, useDisconnect } from 'wagmi';
import {VaultController} from './components/VaultController'; 
function App() {
  const { address, isConnected } = useAccount();
  const { connectors, connect } = useConnect();
  const { disconnect } = useDisconnect();

  if (!isConnected) {
    return (
      <div className='app'>
        <header className="topbar">
          <div className="brand">
          <span className="brand__mark" aria-hidden="true">
          </span>
          <span className="brand__name">Draco Vault</span>
          <p>Please connect your wallet to interact with the vault.</p>
        {connectors.map((connector) => (
          <button key={connector.uid} onClick={() => connect({ connector })}>
            Connect {connector.name}
          </button>
        ))}
        </div>
        </header>
      </div>
    );
  }

  return (
    <div style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1>Draco Vault</h1>
      <p>Connected Account: {address}</p>
      <button onClick={() => disconnect()}>Disconnect</button>
      
      <VaultController />
    </div>
  );
}

export default App;