import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dapp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Dapp Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Client httpClient;
  late Web3Client ethClient;
  final myAddress = "0xAAbadb8B44730d345a254eE1130b1827010E37f7";

  double _value = 0.0;
  int myAmount = 0;
  // ignore: prefer_typing_uninitialized_variables
  var myData;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://rinkeby.infura.io/v3/d765a52fefd64cb489f89627df856442",
        httpClient);
    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x1E26F75a6e9a58eb661FdD0B542179FEa58cE3e5";
    final contract = DeployedContract(ContractAbi.fromJson(abi, "Coin"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    List<dynamic> result = await query("getBalance", []);
    myData = result[0];
    setState(() {});
  }

  Future<String> withDrawCoin() async {
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("withdrawBalance", [bigAmount]);
    return response;
  }

  Future<String> depositCoin() async {
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("depositBalance", [bigAmount]);

    return response;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credential = EthPrivateKey.fromHex(
        "df118e67c3e51130dfe2c9331522e77dd0ca583e3055c9281e8d64ece5f8bf23");
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(
        credential,
        Transaction.callContract(
            contract: contract,
            function: ethFunction,
            parameters: args,
            maxGas: 100000),
        chainId: 4);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 80),
              margin: const EdgeInsets.all(50),
              child: Text(
                "$myData coins",
                style: const TextStyle(fontSize: 40),
              ),
            ),
            InkWell(
              child: Container(
                margin: const EdgeInsets.only(top: 50),
                height: 40,
                width: 200,
                color: Colors.lightBlue,
                child: const Center(
                  child: Text(
                    "REFRESH",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              onTap: () {
                getBalance(myAddress);
              },
            ),
            const Divider(
              height: 50,
            ),
            SfSlider(
              min: 0.0,
              max: 10.0,
              value: _value,
              interval: 1,
              showTicks: true,
              showLabels: true,
              enableTooltip: true,
              minorTicksPerInterval: 1,
              onChanged: (dynamic value) {
                setState(() {
                  _value = value;
                  myAmount = value.round();
                });
              },
            ),
            InkWell(
              child: Container(
                margin: const EdgeInsets.only(top: 50),
                height: 40,
                width: 200,
                color: Colors.lightBlue,
                child: const Center(
                  child: Text(
                    "DEPOSIT",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              onTap: () {
                depositCoin();
              },
            ),
            InkWell(
              child: Container(
                margin: const EdgeInsets.only(top: 50),
                height: 40,
                width: 200,
                color: Colors.greenAccent,
                child: const Center(
                  child: Text(
                    "WITHDRAW",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              onTap: () {
                withDrawCoin();
              },
            ),
            Container(
              padding: const EdgeInsets.only(top: 150),
              child: const Center(
                child: Text(
                  "Coins",
                  style: TextStyle(fontSize: 30, color: Colors.black45),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
//end
//shubham khodape