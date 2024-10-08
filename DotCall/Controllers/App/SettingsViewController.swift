//
//  SettingsViewController.swift
//  DotCall
//
//  Created by Ahmed Anwer on 2024-05-02.
//

import FirebaseAuth
import UIKit
import RealmSwift


// MARK: - EditProfileDelegate

extension SettingsViewController: EditProfileDelegate {
    func didUpdateUserProfile() {
        tableView.reloadData()
    }
}

// MARK: - SettingsViewController

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    @IBAction func EditButtonPressed(_ sender: UIBarButtonItem) {
        impactOccur()
        performSegue(withIdentifier: "EdittoCheck", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editProfileVC = segue.destination as? EditProfileViewController {
            editProfileVC.delegate = self
        }
    }

   
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        switch section {
        case .Image:
            return 1
        case .Profile:
            return ProfileOptions.allCases.count
        case .General:
            return GeneralnOptions.allCases.count
        case .LogOut:
            return LogOutOptions.allCases.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .Image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileImageCell", for: indexPath) as! ProfileImageViewCell
            cell.backgroundColor = .clear
            
            cell.contactName.text = UserProfile.shared.generalProfile.name

            //cell.profileImage.image = UIImage(named: "your_profile_image_name")
            
            return cell
            
        case .Profile:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsViewCell
            
            let profile = ProfileOptions(rawValue: indexPath.row)
            cell.sectionType = profile
            cell.backgroundColor = UIColor.iosBoxBG
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.detailTextLabel?.textColor = .gray
            cell.detailTextLabel?.textAlignment = .right
            cell.selectionStyle = .none
        
            
            // Set the detail text based on the option
            switch profile {
            case .name:
                cell.detailTextLabel?.text = UserProfile.shared.generalProfile.name
            case .email:
                cell.detailTextLabel?.text = UserProfile.shared.generalProfile.email
            case .username:
                cell.detailTextLabel?.text = UserProfile.shared.generalProfile.username
            default:
                cell.detailTextLabel?.text = ""
            }
            
            // Set the image
            if let imageName = profile?.imageName {
                cell.imageView?.image = UIImage(systemName: imageName)
                cell.imageView?.tintColor = .backButton
            }
            
            return cell
            
        case .General:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralSettingsCell", for: indexPath) as! GeneralSettingsViewCell
            
            if let general = GeneralnOptions(rawValue: indexPath.row) {
                cell.sectionType = general
                cell.backgroundColor = UIColor.iosBoxBG
                cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
                cell.selectionStyle = .none
                
                if !general.imageName.isEmpty {
                    cell.imageView?.image = UIImage(systemName: general.imageName)
                    cell.imageView?.tintColor = .backButton
                }
                switch general {
                case .notification:
                    cell.switchControl.isOn = UserProfile.shared.settingsProfile.notification ?? false
                case .faceId:
                    cell.switchControl.isOn = UserProfile.shared.settingsProfile.faceId ?? false
                case .haptic:
                    cell.switchControl.isOn = UserProfile.shared.settingsProfile.haptic ?? false
                }
            }
            return cell
            
        case .LogOut:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogOutViewCell", for: indexPath) as! LogOutViewCell
            
            let logout = LogOutOptions(rawValue: indexPath.row)
            cell.sectionType = logout
            cell.backgroundColor = UIColor.iosBoxBG
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            cell.textLabel?.textColor = UIColor.red
            cell.clipsToBounds = true
            cell.layer.cornerRadius = CGFloat(K.borderRadius)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.layoutMargins = UIEdgeInsets.zero
            cell.preservesSuperviewLayoutMargins = false
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        switch section {
        case .Image:
            return 0
        default:
            return 40
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = SettingsSection(rawValue: section) else { return nil }
        if section == .Image {
            return nil
        } else {
            let view = UIView()
            view.backgroundColor = .IOSBG

            let title = UILabel()
            title.font = UIFont.systemFont(ofSize: 16)
            title.textColor = .sectionHeader
            title.text = SettingsSection(rawValue: section.rawValue)?.description
            view.addSubview(title)
            title.translatesAutoresizingMaskIntoConstraints = false
            title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true

            return view
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let section = SettingsSection(rawValue: indexPath.section) {
            switch section {
            case .Profile:
                return 53
            case .General:
                return 58
            case .LogOut:
                return 62
            default:
                return UITableView.automaticDimension
            }
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        switch section {
        case .Image, .Profile, .General:
            return
        case .LogOut:
            impactOccur()
            showLogoutConfirmation()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - Private Methods

private extension SettingsViewController {
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .IOSBG
        tableView.register(SettingsViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(GeneralSettingsViewCell.self, forCellReuseIdentifier: "GeneralSettingsCell")
        tableView.register(LogOutViewCell.self, forCellReuseIdentifier: "LogOutViewCell")
        tableView.register(UINib(nibName: "ProfileImageViewCell", bundle: nil), forCellReuseIdentifier: "ProfileImageCell")

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            self.signOutUser()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func signOutUser() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
            
            try Auth.auth().signOut()
            print("Sign out successful")

            UserProfile.shared.logOut()
            AuthManager.shared.resetState()
        } catch let error as NSError {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    private func impactOccur(){
        if UserProfile.shared.settingsProfile.haptic == true {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }
    }
}

