Summary

- [unused-return](#unused-return) (1 results) (Medium)
- [assembly](#assembly) (2 results) (Informational)
- [low-level-calls](#low-level-calls) (1 results) (Informational)
- [naming-convention](#naming-convention) (2 results) (Informational)

## unused-return

Impact: Medium
Confidence: Medium

- [ ] ID-0
      [PriceProvider.estimateAmountOut(address,uint128)](src/PriceProvider.sol#L56-L77) ignores return value by [(tick) = OracleLibrary.consult(pool,secondsAgo)](src/PriceProvider.sol#L70)

src/PriceProvider.sol#L56-L77

## assembly

Impact: Informational
Confidence: High

- [ ] ID-1
      [Proxy.\_setImplementation(address)](src/Proxy.sol#L112-L117) uses assembly - [INLINE ASM](src/Proxy.sol#L114-L116)

src/Proxy.sol#L112-L117

- [ ] ID-2
      [Proxy.fallback(bytes)](src/Proxy.sol#L87-L105) uses assembly - [INLINE ASM](src/Proxy.sol#L92-L94)

src/Proxy.sol#L87-L105

## low-level-calls

Impact: Informational
Confidence: High

- [ ] ID-3
      Low level call in [Proxy.fallback(bytes)](src/Proxy.sol#L87-L105): - [(success,resultData) = implementation.delegatecall(callData)](src/Proxy.sol#L98)

src/Proxy.sol#L87-L105

## naming-convention

Impact: Informational
Confidence: High

- [ ] ID-4
      Parameter [Proxy.upgradeTo(address).\_implementation](src/Proxy.sol#L80) is not in mixedCase

src/Proxy.sol#L80

- [ ] ID-5
      Parameter [Multisig.proposeUpgrade(address).\_newContract](src/Multisig.sol#L139) is not in mixedCase

src/Multisig.sol#L139

INFO:Slither:. analyzed (20 contracts with 93 detectors), 6 result(s) found
