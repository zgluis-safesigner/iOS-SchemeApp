import UIKit
struct InsertTransactionResponse: Codable {
    let statusCode: Int?
    let statusDescription: String?
    let transactionId: String?
    let token: String?
}
class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tituloInput: UITextField!
    @IBOutlet weak var subtituloInput: UITextField!
    
    @IBOutlet weak var llave1: UITextField!
    @IBOutlet weak var llave2: UITextField!
    @IBOutlet weak var llave3: UITextField!
    
    @IBOutlet weak var valor1: UITextField!
    @IBOutlet weak var valor2: UITextField!
    @IBOutlet weak var valor3: UITextField!
    
    fileprivate var activeField: UITextField?
    @IBOutlet weak var theScrollView: UIScrollView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let urlInsertTransaction = "https://dev.safesigner.com/mobisigner-qa/api/transaction/insert"
    //QA= https://104.196.154.57/mobisigner-qa/api/transaction/insert
    //LOCAL=http://192.168.1.170:8080/mobisigner-qa/api/transaction/insert
    let authToken: String = "MjgtYmRkNjdmMjUtNDM2NC00N2QzLWE3ZGUtOGNiZDU0NGY4YjNm"
    
    var token: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        self.activityIndicator.hidesWhenStopped = true
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        tituloInput.text = "Transferencia de Fondos"
        subtituloInput.text = "Operación bancaría interna"

        llave1.delegate = self
        llave1.text = "Banco"
        valor1.delegate = self
        valor1.text = "Banco Empresarial"
        
        llave2.delegate = self
        llave2.text = "Cuenta"
        valor2.delegate = self
        valor2.text = "Corriente"

        llave3.delegate = self
        llave3.text = "Monto"
        valor3.delegate = self
        valor3.text = "$1.000"

    }
    @IBAction func InserTransactionButton(_ sender: Any) {
        doPost()
    }
    
    @IBAction func LaunchButton(_ sender: Any) {
        
        //Bice:326295
        //Consorcio:023264
        launchApp(decodedURL: "mobisigner://transaction?color=326295&token=" + token)
    }
    
    func launchApp(decodedURL: String) {
        if let url = URL(string: decodedURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func doPost(){
        let jsonData = try? JSONSerialization.data(withJSONObject: getJsonReq())
        let url = URL(string: urlInsertTransaction)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        print("sending json", getJsonReq())
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        print("Requesting... ")
        activityIndicator.startAnimating()

        let task = URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil {
                do {
                    let response = try JSONDecoder().decode(InsertTransactionResponse.self, from: data!)
                    print("Response... " ,response)
                    self.token = response.token ?? ""
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.launchApp(decodedURL: "mobisigner://transaction?color=326295&token=" + self.token)

                    }
                } catch let err {
                    self.activityIndicator.stopAnimating()

                    print("Error parseando respuesta", err)
                    print("Data: ", data!)
                }
            } else {
                self.activityIndicator.stopAnimating()

                print("Error ejecutando llamado:", error ?? "Error null")
            }
        }
        task.resume()
    }
    
    func getJsonReq() -> [String: Any]{
        let jsonReq: [String: Any] = [
            "docType": "2",
            "name": "Transaccion de Prueba",
            "metadata": ["documentUrl": "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy"],
            "transactionData": "<transactionData><title>" + tituloInput.text! + "</title><subtitle>" + subtituloInput.text! + "</subtitle><data><element><key>" + llave1.text! + "</key><value>" + valor1.text! + "</value></element><element><key>" + llave2.text! + "</key><value>" + valor2.text! + "</value></element><element><key>" + llave3.text! + "</key><value>" + valor3.text! + "</value></element></data></transactionData>",
            "signers": [["email": "luis.zapata@safesigner.com", "userId": "263105036"]]
        ]
        
        return jsonReq
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    //Keyboard Controls
    @objc func keyboardWillShow(notification:NSNotification){
        print("keyboard will show")
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.theScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        theScrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        theScrollView.contentInset = contentInset
    }
}
