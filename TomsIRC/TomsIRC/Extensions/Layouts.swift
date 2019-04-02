
import UIKit

extension MessageTableViewCell {
  override func layoutSubviews() {
    super.layoutSubviews()
    

      messageLabel.font = UIFont(name: "Arial", size: 17) //UIFont.systemFont(ofSize: 17)
      nameLabel.font = UIFont(name: "Arial-BoldMT", size: 17) //UIFont.systemFont(ofSize: 17)
    
      messageLabel.textColor = .white
      
      let size = messageLabel.sizeThatFits(CGSize(width: 2*(bounds.size.width/3), height: CGFloat.greatestFiniteMagnitude))
      messageLabel.frame = CGRect(x: 0, y: 0, width: size.width + 2, height: size.height + 0)
      
      if messageSender == .ourself
      {
        nameLabel.isHidden = true
        
        messageLabel.center = CGPoint(x: bounds.size.width - messageLabel.bounds.size.width/2.0 - 16, y: bounds.size.height/2.0)
        messageLabel.backgroundColor = .white
        messageLabel.sizeToFit()
        
      } else {
        nameLabel.isHidden = false
        nameLabel.sizeToFit()
        nameLabel.backgroundColor = .white
        nameLabel.center = CGPoint(x: nameLabel.bounds.size.width/2.0 + 16 + 4, y: nameLabel.bounds.size.height/2.0 + 4)
        
        messageLabel.center = CGPoint(x: messageLabel.bounds.size.width/2.0 + 16, y: messageLabel.bounds.size.height/2.0 + nameLabel.bounds.size.height + 8)
        messageLabel.backgroundColor = .white
        messageLabel.textColor = .darkGray
        messageLabel.sizeToFit()
      }
    
    
//    messageLabel.layer.cornerRadius = min(messageLabel.bounds.size.height/2.0, 20)
  }
  

}
