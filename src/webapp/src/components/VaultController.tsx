import { useReadContract, useWriteContract } from 'wagmi';
import VaultArtifact from '../../../../out/Vault.sol/TreasuryVault.json';

export function VaultController() {
  const vaultAddress = '0xd33c0d05358dd357ffa034fd708bc6f57fb536c2' as `0x${string}`;
  const vaultAbi = VaultArtifact.abi;

  const { data: balance } = useReadContract({
    address: vaultAddress,
    abi: vaultAbi,
    functionName: 'getBalance',
  });

  return (
    <div>
      <h3>Vault Status</h3>
      <p>Balance: {balance?.toString() ?? 'Loading...'}</p>
    </div>
  );
}