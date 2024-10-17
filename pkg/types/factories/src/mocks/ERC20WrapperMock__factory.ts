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
import type { NonPayableOverrides } from "../../../common";
import type {
  ERC20WrapperMock,
  ERC20WrapperMockInterface,
} from "../../../src/mocks/ERC20WrapperMock";

const _abi = [
  {
    inputs: [
      {
        internalType: "contract IERC20",
        name: "token",
        type: "address",
      },
      {
        internalType: "string",
        name: "_name",
        type: "string",
      },
      {
        internalType: "string",
        name: "_symbol",
        type: "string",
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
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Approval",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Transfer",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
    ],
    name: "allowance",
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
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "approve",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "balanceOf",
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
    inputs: [],
    name: "decimals",
    outputs: [
      {
        internalType: "uint8",
        name: "",
        type: "uint8",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "subtractedValue",
        type: "uint256",
      },
    ],
    name: "decreaseAllowance",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "depositFor",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "addedValue",
        type: "uint256",
      },
    ],
    name: "increaseAllowance",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "name",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "setBalance",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "symbol",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "totalSupply",
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
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "transfer",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "transferFrom",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "underlying",
    outputs: [
      {
        internalType: "contract IERC20",
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
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "withdrawTo",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

const _bytecode =
  "0x60a060405234620003a15762001a55803803806200001d81620003a6565b928339810190606081830312620003a1578051916001600160a01b038316808403620003a1576020838101516001600160401b039491939190858111620003a157826200006c918301620003cc565b916040820151868111620003a157620000869201620003cc565b938151818111620002a1576003908154906001948583811c9316801562000396575b8884101462000380578190601f938481116200032a575b508890848311600114620002c357600092620002b7575b505060001982851b1c191690851b1782555b8651928311620002a15760049687548581811c9116801562000296575b88821014620002815782811162000236575b5086918411600114620001cb57938394918492600095620001bf575b50501b92600019911b1c19161783555b30146200017c578260805260405161161690816200043f823960805181818161050b01528181610699015281816109560152610cd90152f35b60405162461bcd60e51b815291820152601e60248201527f4552433230577261707065723a2063616e6e6f742073656c6620777261700000604482015260649150fd5b01519350388062000133565b9190601f198416928860005284886000209460005b8a898383106200021e575050501062000203575b50505050811b01835562000143565b01519060f884600019921b161c1916905538808080620001f4565b868601518955909701969485019488935001620001e0565b88600052876000208380870160051c8201928a881062000277575b0160051c019086905b8281106200026a57505062000117565b600081550186906200025a565b9250819262000251565b602289634e487b7160e01b6000525260246000fd5b90607f169062000105565b634e487b7160e01b600052604160045260246000fd5b015190503880620000d6565b90879350601f19831691866000528a6000209260005b8c828210620003135750508411620002fa575b505050811b018255620000e8565b015160001983871b60f8161c19169055388080620002ec565b8385015186558b97909501949384019301620002d9565b90915084600052886000208480850160051c8201928b861062000376575b918991869594930160051c01915b82811062000366575050620000bf565b6000815585945089910162000356565b9250819262000348565b634e487b7160e01b600052602260045260246000fd5b92607f1692620000a8565b600080fd5b6040519190601f01601f191682016001600160401b03811183821017620002a157604052565b919080601f84011215620003a15782516001600160401b038111620002a15760209062000402601f8201601f19168301620003a6565b92818452828287010111620003a15760005b8181106200042a57508260009394955001015290565b85810183015184820184015282016200041456fe608060408181526004918236101561001657600080fd5b600092833560e01c91826306fdde0314610a2b57508163095ea7b3146109e357816318160ddd146109a6578163205c28781461089f57816323b872dd146107715781632f4f21e2146105ee578163313ce567146105a9578163395093511461052f5781636f307dc3146104c057816370a082311461045f57816395d89b4114610305578163a457c2d7146101ff57508063a9059cbb146101b1578063dd62ed3e1461013e5763e30443bc146100ca57600080fd5b3461013a57807ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261013a576101379061012e610107610bdb565b9173ffffffffffffffffffffffffffffffffffffffff831685528460205284205482610f01565b6024359061128d565b80f35b5080fd5b503461013a57807ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261013a5780602092610179610bdb565b610181610c03565b73ffffffffffffffffffffffffffffffffffffffff91821683526001865283832091168252845220549051908152f35b503461013a57807ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261013a576020906101f86101ee610bdb565b602435903361107e565b5160018152f35b9050823461030257827ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261030257610238610bdb565b918360243592338152600160205281812073ffffffffffffffffffffffffffffffffffffffff8616825260205220549082821061027f576020856101f88585038733610d8c565b60849060208651917f08c379a0000000000000000000000000000000000000000000000000000000008352820152602560248201527f45524332303a2064656372656173656420616c6c6f77616e63652062656c6f7760448201527f207a65726f0000000000000000000000000000000000000000000000000000006064820152fd5b80fd5b83833461013a57817ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261013a5780519180938054916001908360011c9260018516948515610455575b6020958686108114610429578589529081156103e7575060011461038f575b61038b8787610381828c0383610c26565b5191829182610b75565b0390f35b81529295507f8a35acfbc15ff81a39ae7d344fd709f28e8600b4aa8c65c6b64bfe7fe36bd19b5b8284106103d4575050508261038b9461038192820101948680610370565b80548685018801529286019281016103b6565b7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00168887015250505050151560051b83010192506103818261038b8680610370565b6024846022857f4e487b7100000000000000000000000000000000000000000000000000000000835252fd5b93607f1693610351565b50503461013a5760207ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261013a578060209273ffffffffffffffffffffffffffffffffffffffff6104b1610bdb565b16815280845220549051908152f35b50503461013a57817ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261013a576020905173ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000168152f35b50503461013a57807ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261013a576101f86020926105a2610570610bdb565b913381526001865284812073ffffffffffffffffffffffffffffffffffffffff84168252865284602435912054610d50565b9033610d8c565b50503461013a57817ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261013a5760209060ff6105e6610c96565b915191168152f35b82843461030257817ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261030257610626610bdb565b602435913033146106ee578351907f23b872dd0000000000000000000000000000000000000000000000000000000060208301523360248301523060448301528360648301526064825260a082019082821067ffffffffffffffff8311176106c2576020866101f887876106bd888886527f0000000000000000000000000000000000000000000000000000000000000000611356565b61128d565b806041887f4e487b71000000000000000000000000000000000000000000000000000000006024945252fd5b60848560208651917f08c379a0000000000000000000000000000000000000000000000000000000008352820152602360248201527f4552433230577261707065723a20777261707065722063616e2774206465706f60448201527f73697400000000000000000000000000000000000000000000000000000000006064820152fd5b8391503461013a5760607ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261013a576107ab610bdb565b6107b3610c03565b91846044359473ffffffffffffffffffffffffffffffffffffffff8416815260016020528181203382526020522054907fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8203610819575b6020866101f887878761107e565b8482106108425750918391610837602096956101f895033383610d8c565b91939481935061080b565b60649060208751917f08c379a0000000000000000000000000000000000000000000000000000000008352820152601d60248201527f45524332303a20696e73756666696369656e7420616c6c6f77616e63650000006044820152fd5b82843461030257817ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc360112610302576108d7610bdb565b906024356108e58133610f01565b73ffffffffffffffffffffffffffffffffffffffff8451937fa9059cbb000000000000000000000000000000000000000000000000000000006020860152166024840152604483015260448252608082019082821067ffffffffffffffff83111761097a576020846101f8858583527f0000000000000000000000000000000000000000000000000000000000000000611356565b806041867f4e487b71000000000000000000000000000000000000000000000000000000006024945252fd5b50503461013a57817ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261013a576020906002549051908152f35b50503461013a57807ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261013a576020906101f8610a21610bdb565b6024359033610d8c565b92915034610b7157837ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc360112610b7157600354600181811c9186908281168015610b67575b6020958686108214610b3b5750848852908115610afb5750600114610aa2575b61038b8686610381828b0383610c26565b929550600383527fc2575a0e9e593c00f959f8c92f12db2869c3395a3b0502d05e2516446f71f85b5b828410610ae8575050508261038b94610381928201019438610a91565b8054868501880152928601928101610acb565b7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff001687860152505050151560051b83010192506103818261038b38610a91565b8360226024927f4e487b7100000000000000000000000000000000000000000000000000000000835252fd5b93607f1693610a71565b8380fd5b60208082528251818301819052939260005b858110610bc7575050507fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0601f8460006040809697860101520116010190565b818101830151848201604001528201610b87565b6004359073ffffffffffffffffffffffffffffffffffffffff82168203610bfe57565b600080fd5b6024359073ffffffffffffffffffffffffffffffffffffffff82168203610bfe57565b90601f7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0910116810190811067ffffffffffffffff821117610c6757604052565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b6040517f313ce56700000000000000000000000000000000000000000000000000000000815260208160048173ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000165afa8091600091610d14575b5090610d115750601290565b90565b6020813d602011610d48575b81610d2d60209383610c26565b8101031261013a57519060ff82168203610302575038610d05565b3d9150610d20565b91908201809211610d5d57565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b73ffffffffffffffffffffffffffffffffffffffff809116918215610e7e5716918215610dfa5760207f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925918360005260018252604060002085600052825280604060002055604051908152a3565b60846040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602260248201527f45524332303a20617070726f766520746f20746865207a65726f20616464726560448201527f73730000000000000000000000000000000000000000000000000000000000006064820152fd5b60846040517f08c379a0000000000000000000000000000000000000000000000000000000008152602060048201526024808201527f45524332303a20617070726f76652066726f6d20746865207a65726f2061646460448201527f72657373000000000000000000000000000000000000000000000000000000006064820152fd5b73ffffffffffffffffffffffffffffffffffffffff168015610ffa57600091818352826020526040832054818110610f7657817fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef926020928587528684520360408620558060025403600255604051908152a3565b60846040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602260248201527f45524332303a206275726e20616d6f756e7420657863656564732062616c616e60448201527f63650000000000000000000000000000000000000000000000000000000000006064820152fd5b60846040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602160248201527f45524332303a206275726e2066726f6d20746865207a65726f2061646472657360448201527f73000000000000000000000000000000000000000000000000000000000000006064820152fd5b73ffffffffffffffffffffffffffffffffffffffff80911691821561120957169182156111855760008281528060205260408120549180831061110157604082827fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef958760209652828652038282205586815220818154019055604051908152a3565b60846040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602660248201527f45524332303a207472616e7366657220616d6f756e742065786365656473206260448201527f616c616e636500000000000000000000000000000000000000000000000000006064820152fd5b60846040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602360248201527f45524332303a207472616e7366657220746f20746865207a65726f206164647260448201527f65737300000000000000000000000000000000000000000000000000000000006064820152fd5b60846040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602560248201527f45524332303a207472616e736665722066726f6d20746865207a65726f20616460448201527f64726573730000000000000000000000000000000000000000000000000000006064820152fd5b73ffffffffffffffffffffffffffffffffffffffff169081156112f8577fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef6020826112dc600094600254610d50565b60025584845283825260408420818154019055604051908152a3565b60646040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601f60248201527f45524332303a206d696e7420746f20746865207a65726f2061646472657373006044820152fd5b73ffffffffffffffffffffffffffffffffffffffff16906040516040810167ffffffffffffffff9082811082821117610c67576040526020938483527f5361666545524332303a206c6f772d6c6576656c2063616c6c206661696c6564858401526000808587829751910182855af1903d1561150d573d9283116114e0579061141d93929160405192611410887fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0601f8401160185610c26565b83523d868885013e611518565b8051918215918483156114bc575b5050509050156114385750565b608490604051907f08c379a00000000000000000000000000000000000000000000000000000000082526004820152602a60248201527f5361666545524332303a204552433230206f7065726174696f6e20646964206e60448201527f6f742073756363656564000000000000000000000000000000000000000000006064820152fd5b91938180945001031261013a5782015190811515820361030257508038808461142b565b6024857f4e487b710000000000000000000000000000000000000000000000000000000081526041600452fd5b9061141d9392506060915b91929015611593575081511561152c575090565b3b156115355790565b60646040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601d60248201527f416464726573733a2063616c6c20746f206e6f6e2d636f6e74726163740000006044820152fd5b8251909150156115a65750805190602001fd5b6115dc906040519182917f08c379a000000000000000000000000000000000000000000000000000000000835260048301610b75565b0390fdfea26469706673582212200a97255958d16c515ba0374c5722eef9186230a45f8ef65d5c0fc036c6d9ee1264736f6c63430008180033";

type ERC20WrapperMockConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: ERC20WrapperMockConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class ERC20WrapperMock__factory extends ContractFactory {
  constructor(...args: ERC20WrapperMockConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override getDeployTransaction(
    token: AddressLike,
    _name: string,
    _symbol: string,
    overrides?: NonPayableOverrides & { from?: string }
  ): Promise<ContractDeployTransaction> {
    return super.getDeployTransaction(token, _name, _symbol, overrides || {});
  }
  override deploy(
    token: AddressLike,
    _name: string,
    _symbol: string,
    overrides?: NonPayableOverrides & { from?: string }
  ) {
    return super.deploy(token, _name, _symbol, overrides || {}) as Promise<
      ERC20WrapperMock & {
        deploymentTransaction(): ContractTransactionResponse;
      }
    >;
  }
  override connect(runner: ContractRunner | null): ERC20WrapperMock__factory {
    return super.connect(runner) as ERC20WrapperMock__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): ERC20WrapperMockInterface {
    return new Interface(_abi) as ERC20WrapperMockInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): ERC20WrapperMock {
    return new Contract(address, _abi, runner) as unknown as ERC20WrapperMock;
  }
}
