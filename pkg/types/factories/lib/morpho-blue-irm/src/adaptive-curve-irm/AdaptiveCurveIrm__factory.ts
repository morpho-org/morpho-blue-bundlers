/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import {
  Contract,
  ContractFactory,
  ContractTransactionResponse,
  Interface,
} from "ethers";
import type {
  Signer,
  AddressLike,
  ContractDeployTransaction,
  ContractRunner,
} from "ethers";
import type { NonPayableOverrides } from "../../../../../common";
import type {
  AdaptiveCurveIrm,
  AdaptiveCurveIrmInterface,
} from "../../../../../lib/morpho-blue-irm/src/adaptive-curve-irm/AdaptiveCurveIrm";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "morpho",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "Id",
        name: "id",
        type: "bytes32",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "avgBorrowRate",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "rateAtTarget",
        type: "uint256",
      },
    ],
    name: "BorrowRateUpdate",
    type: "event",
  },
  {
    inputs: [],
    name: "MORPHO",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        components: [
          {
            internalType: "address",
            name: "loanToken",
            type: "address",
          },
          {
            internalType: "address",
            name: "collateralToken",
            type: "address",
          },
          {
            internalType: "address",
            name: "oracle",
            type: "address",
          },
          {
            internalType: "address",
            name: "irm",
            type: "address",
          },
          {
            internalType: "uint256",
            name: "lltv",
            type: "uint256",
          },
        ],
        internalType: "struct MarketParams",
        name: "marketParams",
        type: "tuple",
      },
      {
        components: [
          {
            internalType: "uint128",
            name: "totalSupplyAssets",
            type: "uint128",
          },
          {
            internalType: "uint128",
            name: "totalSupplyShares",
            type: "uint128",
          },
          {
            internalType: "uint128",
            name: "totalBorrowAssets",
            type: "uint128",
          },
          {
            internalType: "uint128",
            name: "totalBorrowShares",
            type: "uint128",
          },
          {
            internalType: "uint128",
            name: "lastUpdate",
            type: "uint128",
          },
          {
            internalType: "uint128",
            name: "fee",
            type: "uint128",
          },
        ],
        internalType: "struct Market",
        name: "market",
        type: "tuple",
      },
    ],
    name: "borrowRate",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        components: [
          {
            internalType: "address",
            name: "loanToken",
            type: "address",
          },
          {
            internalType: "address",
            name: "collateralToken",
            type: "address",
          },
          {
            internalType: "address",
            name: "oracle",
            type: "address",
          },
          {
            internalType: "address",
            name: "irm",
            type: "address",
          },
          {
            internalType: "uint256",
            name: "lltv",
            type: "uint256",
          },
        ],
        internalType: "struct MarketParams",
        name: "marketParams",
        type: "tuple",
      },
      {
        components: [
          {
            internalType: "uint128",
            name: "totalSupplyAssets",
            type: "uint128",
          },
          {
            internalType: "uint128",
            name: "totalSupplyShares",
            type: "uint128",
          },
          {
            internalType: "uint128",
            name: "totalBorrowAssets",
            type: "uint128",
          },
          {
            internalType: "uint128",
            name: "totalBorrowShares",
            type: "uint128",
          },
          {
            internalType: "uint128",
            name: "lastUpdate",
            type: "uint128",
          },
          {
            internalType: "uint128",
            name: "fee",
            type: "uint128",
          },
        ],
        internalType: "struct Market",
        name: "market",
        type: "tuple",
      },
    ],
    name: "borrowRateView",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "Id",
        name: "",
        type: "bytes32",
      },
    ],
    name: "rateAtTarget",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

const _bytecode =
  "0x60a03461011c57601f19610a3538819003601f810183168401936001600160401b03939092909183861085871117610106578084926040978852833960209384918101031261011c5751926001600160a01b03841680850361011c5785519182870190811183821017610106578652600c82526b7a65726f206164647265737360a01b84830152156100ad57505050608052516109139081610122823960805181818160bc015261026b0152f35b82855192839162461bcd60e51b835280600484015283519081602485015260005b8281106100ef5750506044935080600085601f938601015201168101030190fd5b8086018201518782016044015286945081016100ce565b634e487b7160e01b600052604160045260246000fd5b600080fdfe6080604090808252600436101561001557600080fd5b600090813560e01c90816301977b571461028f575080633acb5624146102205780638c00bf6b146101f457639451fed41461004f57600080fd5b346101f15761005d366102d6565b8351939184830167ffffffffffffffff8111868210176101c4578352600a85526020947f6e6f74204d6f7270686f000000000000000000000000000000000000000000008682015273ffffffffffffffffffffffffffffffffffffffff7f00000000000000000000000000000000000000000000000000000000000000001633036101315750828061011460a07f7120161a7b3d31251e01294ab351ef15a41b91659a36032e4641bb89b121e321942094856104ff565b91878684939952808a52205581519086825287820152a251908152f35b84908685519283917f08c379a0000000000000000000000000000000000000000000000000000000008352806004840152835193846024850152825b8581106101ad57505050601f837fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe092604480968601015201168101030190fd5b81810183015187820160440152869450820161016d565b6024857f4e487b710000000000000000000000000000000000000000000000000000000081526041600452fd5b80fd5b50903461021c5760209061021460a061020c366102d6565b9190206104ff565b509051908152f35b5080fd5b50903461021c57817ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261021c576020905173ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000168152f35b905082346102d25760207ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126102d257602092600435815280845220548152f35b8280fd5b907ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc820161016081126104415760a013610441576040805167ffffffffffffffff919060a081018381118282101761044657825273ffffffffffffffffffffffffffffffffffffffff6004358181168103610441578252602435818116810361044157602083015260443581811681036104415783830152606435908116810361044157817fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5c91606060c094015260843560808201529501126104415780519160c08301908111838210176104465781526fffffffffffffffffffffffffffffffff9060a435828116810361044157835260c435828116810361044157602084015260e435908282168203610441578301526101043581811681036104415760608301526101243581811681036104415760808301526101443590811681036104415760a082015290565b600080fd5b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b8181029291600082127f80000000000000000000000000000000000000000000000000000000000000008214166104b45781840514901517156104b457565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b919091600083820193841291129080158216911516176104b457565b81519092916fffffffffffffffffffffffffffffffff91821680156000816107c357508360408401511690670de0b6b3a7640000918281029281840414901517156104b45761078f5704915b670c7d713b49da0000808413156107be575067016345785d8a00005b7ffffffffffffffffffffffffffffffffffffffffffffffffff3828ec4b626000084019384136001166104b457670de0b6b3a764000093848102908082058614901517156104b457811561078f577fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff82147f80000000000000000000000000000000000000000000000000000000000000008214166104b4570594600052600060205260406000205491600091831560001461067a5750505050634b9a1eff8161064482955b600081121561066c57670a688906bd8b0000610475565b059082820191600084841291129080158216911516176104b45761066791610475565b059190565b6729a2241af62c0000610475565b650171268b5ad49187830292830588036107625760800151164203904282116107355790846106a99205610475565b806106bb57505081610644829561062d565b906106e1826106db6106d1869560029a976107cc565b98899205856107cc565b936104e3565b908260011b926002840503610708575060046107018593610644936104e3565b059261062d565b807f4e487b7100000000000000000000000000000000000000000000000000000000602492526011600452fd5b6024837f4e487b710000000000000000000000000000000000000000000000000000000081526011600452fd5b6024847f4e487b710000000000000000000000000000000000000000000000000000000081526011600452fd5b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601260045260246000fd5b610567565b9150509161054b565b6107e8906107e2670de0b6b3a764000093610807565b90610475565b05640ec41a0ddf81811290821802186301e3da5f818113908218021890565b7ffffffffffffffffffffffffffffffffffffffffffffffffdc0d0570925a462d881126108d7576805168fd0946fc0415f8112156108b95760008112156108aa577ffffffffffffffffffffffffffffffffffffffffffffffffffb30b927e6d498d2905b67099e8db03256ce5d80928201059182029003670de0b6b3a764000090600282828002050501019060008112156000146108a3571b90565b6000031d90565b6704cf46d8192b672e9061086b565b50780931d81650c7d88b800000000000000000000000000000000090565b5060009056fea2646970667358221220d4847f6facad80865a8f008ad4657ec47c398534bf2f09f326fe1518525a760664736f6c63430008130033";

type AdaptiveCurveIrmConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: AdaptiveCurveIrmConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class AdaptiveCurveIrm__factory extends ContractFactory {
  constructor(...args: AdaptiveCurveIrmConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override getDeployTransaction(
    morpho: AddressLike,
    overrides?: NonPayableOverrides & { from?: string }
  ): Promise<ContractDeployTransaction> {
    return super.getDeployTransaction(morpho, overrides || {});
  }
  override deploy(
    morpho: AddressLike,
    overrides?: NonPayableOverrides & { from?: string }
  ) {
    return super.deploy(morpho, overrides || {}) as Promise<
      AdaptiveCurveIrm & {
        deploymentTransaction(): ContractTransactionResponse;
      }
    >;
  }
  override connect(runner: ContractRunner | null): AdaptiveCurveIrm__factory {
    return super.connect(runner) as AdaptiveCurveIrm__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): AdaptiveCurveIrmInterface {
    return new Interface(_abi) as AdaptiveCurveIrmInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): AdaptiveCurveIrm {
    return new Contract(address, _abi, runner) as unknown as AdaptiveCurveIrm;
  }
}
