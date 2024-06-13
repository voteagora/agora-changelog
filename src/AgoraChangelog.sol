// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract AgoraChangelog is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    struct Entry {
        string title;
        string markdownText;
        string ipfsHash;
        string tag;
        string projectURL;
        address author;
        uint256 createdAt;
    }

    Entry[] public entries;
    address public manager;
    mapping(address => bool) public whitelist;

    event EntryAdded(
        string title,
        address indexed author,
        string ipfsHash,
        string tag,
        string projectURL,
        uint256 createdAt
    );

    event UserWhitelisted(address indexed user);
    event UserRemovedFromWhitelist(address indexed user);
    event ManagerChanged(
        address indexed oldManager,
        address indexed newManager
    );

    function initialize(address _manager, address _owner) public initializer {
        __Ownable_init(_owner);
        __UUPSUpgradeable_init();
        manager = _manager;
        whitelist[_owner] = true;
        whitelist[manager] = true;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Not authorized to add entries.");
        _;
    }

    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Only the manager can perform this action."
        );
        _;
    }

    function addEntry(
        string memory _title,
        string memory _markdownText,
        string memory _ipfsHash,
        string memory _tag,
        string memory _projectURL,
        uint256 _createdAt
    ) public onlyWhitelisted {
        uint256 entryTimestamp = _createdAt != 0 ? _createdAt : block.timestamp;
        entries.push(
            Entry({
                title: _title,
                markdownText: _markdownText,
                ipfsHash: _ipfsHash,
                tag: _tag,
                projectURL: _projectURL,
                author: msg.sender,
                createdAt: entryTimestamp
            })
        );
        emit EntryAdded(
            _title,
            msg.sender,
            _ipfsHash,
            _tag,
            _projectURL,
            entryTimestamp
        );
    }

    function getEntry(uint256 _entryId) public view returns (Entry memory) {
        require(_entryId < entries.length, "No Changelog entry found.");
        return entries[_entryId];
    }

    function whitelistUser(address _user) public onlyManager {
        whitelist[_user] = true;
        emit UserWhitelisted(_user);
    }

    function removeUserFromWhitelist(address _user) public onlyManager {
        whitelist[_user] = false;
        emit UserRemovedFromWhitelist(_user);
    }

    function changeManager(address _newManager) public onlyOwner {
        address oldManager = manager;
        manager = _newManager;
        whitelist[manager] = true;
        emit ManagerChanged(oldManager, manager);
    }
}
