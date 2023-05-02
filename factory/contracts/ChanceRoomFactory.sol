// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * ========================= VERSION_2.0.0 ==============================
 *   ██       ██████  ████████ ████████    ██      ██ ███    ██ ██   ██
 *   ██      ██    ██    ██       ██       ██      ██ ████   ██ ██  ██
 *   ██      ██    ██    ██       ██       ██      ██ ██ ██  ██ █████
 *   ██      ██    ██    ██       ██       ██      ██ ██  ██ ██ ██  ██
 *   ███████  ██████     ██       ██    ██ ███████ ██ ██   ████ ██   ██    
 * ======================================================================
 *  ================ Open source smart contract on EVM =================
 *   ============== Verify Random Function by ChainLink ===============
 */

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "./interfaces/IChanceRoom.sol";
import "./interfaces/ITemplate.sol";
import "./utils/Power.sol";

/**
 * @title ChanceRoom Factory Contract
 * @dev A smart contract factory that creates ChanceRooms, which are custom NFT-based smart contracts 
 * that hold valuable NFTs.
 * @notice Users can call the newChanceRoom() function in the factory to create their own ChanceRooms, which are 
 * ERC-721 tokens.
 * @dev The tokenURI of the ChanceRooms is generated using base64 encoding of an SVG format that is written inside 
 * the factory contract.
 * @dev Users can use pre-defined templates or submit their own custom templates and implementations to be audited 
 * and verified by the project team.
 * @dev The factory is also an ERC-721 minter, allowing users to mint NFTs and transfer them to their address.
 * @dev The ChanceRoom Factory has a minimum power requirement for the chanceRoom addresses, which is a number of 
 * leading zeros required for the address. Users must mine a salt that generates an address with a power equal to 
 * or greater than the minimum required by the owner.
 * @dev The ChanceRooms allow users to pay a price set by the owner to purchase tickets to join the chanceRoom. The 
 * tickets are numbered from 0 to the total number of users.
 * @dev When the chanceRoom is triggered, a function calls the chain-link VRF to request a random number, and the 
 * winner is selected based on that number. The valuable NFT held by the chanceRoom is transferred to the owner of 
 * the winning ticket, and the locked funds are transferred to the owner and creator of the chanceRoom.
 */
contract ChanceRoomFactory is ERC721Upgradeable, ERC721EnumerableUpgradeable, OwnableUpgradeable {
    using Clones for address;
    using Strings for *;
    using Power for address;

    string[] _implNames; // a list of the name of all implementations existing in the chanceRoomFactory
    string[] _tempNames; // a list of the name of all template existing in the chanceRoomFactory
    
    mapping(string => Cont) _implementations; // implementation name to index and all versions
    mapping(string => Cont) _templates; // template name to index and all versions

    struct Cont {
        uint256 index; // index of implementation in implNames
        address[] addrs; // address list of all versions of the implementation
    }

    mapping(address => uint256) public chanceRoomVersion;

    uint256 public minPower;

    event Clone(
        address indexed creator, 
        string indexed implName, 
        address clonedAddr, 
        uint256 version
    );

    /**
     * @dev Initializes the ChanceRoom Factory contract by calling the initializers of its parent contracts.
     * @dev Sets the contract owner and minimum power requirement for ChanceRoom addresses.
     */
    function initialize() initializer public {
        __Ownable_init();
        __ERC721_init_unchained("ChanceRoom Factory", "CRF");
        minPower = 3;
    }

    /**
     * @dev Creates a new ChanceRoom contract by cloning an existing implementation contract, determined by the 
     * provided name and salt.
     * @param implName The name of the implementation contract to be cloned.
     * @param salt A random value used to determine the address of the new ChanceRoom contract.
     * @return chanceRoomAddr The address of the newly created ChanceRoom contract.
     */
    function newChanceRoom(string memory implName, bytes32 salt) public returns(address chanceRoomAddr) {
        address creatorAddr = msg.sender;
        // Retrieves the latest version of the implementation contract.
        (address implAddr, uint256 implVersion) = implLatestVersion(implName);
        // Clones the implementation contract to create the new ChanceRoom contract.
        chanceRoomAddr = implAddr.cloneDeterministic(salt);
        // Ensures that the power of the new ChanceRoom address is greater than or equal to the minimum power set 
        // by the owner.
        require(chanceRoomAddr.power() >= minPower);
        // Generates a unique token ID for the new ChanceRoom contract.
        uint256 tokenId = uint256(uint160(chanceRoomAddr));
        // Mints a new ERC721 token representing the new ChanceRoom contract and assigns it to the creator.
        _safeMint(creatorAddr, tokenId);
        // Records the version of the implementation contract used to create the new ChanceRoom contract.
        chanceRoomVersion[chanceRoomAddr] = implVersion;
        // Emits an event indicating that a new ChanceRoom contract has been created.
        emit Clone(creatorAddr, IERC721Metadata(implAddr).name(), chanceRoomAddr, implVersion);
    }


    /**
     * @dev Returns the predicted address of the next ChanceRoom that will be cloned by the ChanceRoomFactory using 
     * a specified salt and implementation name.
     * @param implName The name of the implementation contract.
     * @param salt A unique value that is used to generate a deterministic address.
     * @return The predicted address of the next ChanceRoom.
     */
    function determineChanceRoomAddr(
        string memory implName,
        bytes32 salt
    ) public view returns(address) {
        (address implAddr,) = implLatestVersion(implName);
        return implAddr.predictDeterministicAddress(salt, address(this));
    }


    /**
     * @dev Returns an array of addresses representing all cloned ChanceRooms.
     * @return rooms An array of addresses representing all cloned ChanceRooms.
     */
    function chanceRooms() public view returns(address[] memory rooms) {
        uint256 len = totalSupply();
        rooms = new address[](len);

        for(uint256 i; i < len; i++) {
            rooms[i] = address(uint160(tokenByIndex(i)));
        }
    }

    /**
     * @dev Returns an array of cloneable verified implementation names.
     * @return impls An array of cloneable verified implementation names.
     */
    function implNames() public view returns(
        string[] memory impls
    ) {
        return _implNames;
    }

    /**
     * @dev Returns an array of template names that have been verified and are available for use in creating 
     * new ChanceRooms.
     * @return temps An array of template names that have been verified and are available for use in creating 
     * new ChanceRooms.
     */
    function tempNames() public view returns(
        string[] memory temps
    ) {
        return _tempNames;
    }

    /**
     * @notice Returns a list of all versions of a template.
     * @param tempName The name of the template.
     * @return tempAddrs A list of all template versions' addresses.
     */
    function tempList(string memory tempName) public view returns(
        address[] memory tempAddrs
    ) {
        return _templates[tempName].addrs;
    }

    /**
     * @notice Returns a list of all versions of an implementation contract.
     * @param implName The name of the implementation contract.
     * @return implAddrs An array of addresses representing the different versions of the implementation contract.
     */
    function implList(string memory implName) public view returns(
        address[] memory implAddrs
    ) {
        return _implementations[implName].addrs;
    }



    /**
     * @notice Adds a new implementation address to the verified implementations list. If there is already an implementation with the same name,
     * the new address will be added as a new version of the existing implementation.
     * @dev This function can only be called by the owner of the contract.
     * @param implAddr The address of the implementation to add to the list of verified implementations.
     * Requirements:
     *  - only the owner of the contract is allowed to call this function.
     */
    function addImplementation(address implAddr) public onlyOwner {
        (string memory name,) = IChanceRoom(implAddr).implInfo();
        if(_implementations[name].addrs.length == 0) {
            _implementations[name].index = _implNames.length;
            _implNames.push(name);
        }
        _implementations[name].addrs.push(implAddr);
    }

    /**
     * @dev Removes the implementation and all its versions from the verified implementations list.
     * 
     * @param implName The name of the implementation to be removed.
     * 
     * Requirements:
     * 
     * - Only the owner of the contract is allowed to call this function.
     */
    function removeImplementation(string memory implName) public onlyOwner {
        Cont storage impl = _implementations[implName];
        uint256 count = impl.addrs.length;
        for(uint256 i; i < count; i++) {
            delete impl.addrs[i];
        }
        delete _implNames[impl.index];
    }

    /**
     * @notice Adds a new template address to the list of verified templates. If there is
     * already a template with the same name, the new address will be considered a new
     * version of the existing template (just like with implementations).
     *
     * @param tempAddr The address of the new template to be added.
     * 
     * Requirements:
     * 
     * - Only the owner of the contract is allowed to call this function.
     */
    function addTemplate(address tempAddr) public onlyOwner {
        string memory name = ITemplate(tempAddr).name();
        if (_templates[name].addrs.length == 0) {
            _templates[name].index = _tempNames.length;
            _tempNames.push(name);
        }
        _templates[name].addrs.push(tempAddr);
    }

    
    /**
     * @dev Returns the latest version of an implementation.
     * 
     * @param implName The name of the implementation to check.
     * 
     * @return implAddr The address of the latest version of the implementation.
     * @return version The version number of the latest version of the implementation.
     */
    function implLatestVersion(string memory implName) public view returns(address implAddr, uint256 version) {
        version = _implementations[implName].addrs.length;
        require(version != 0, "non existing implementation address");
        implAddr = _implementations[implName].addrs[version - 1];
    }
    
    /**
     * @dev Returns the latest version of a template.
     * 
     * @param tempName The name of the template to check.
     * 
     * @return tempAddr The address of the latest version of the template.
     * @return version The version number of the latest version of the template.
     */
    function tempLatestVersion(string memory tempName) public view returns(address tempAddr, uint256 version) {
        version = _templates[tempName].addrs.length;
        require(version != 0, "non existing template address");
        tempAddr = _templates[tempName].addrs[version - 1];
    }
    
    /**
     * @dev Returns the address of a certain version of a template.
     * 
     * @param tempName The name of the template to check.
     * @param version The version number of the template to get the address for.
     * 
     * @return tempAddr The address of the specified version of the template.
     */
    function tempVersionAddr(string memory tempName, uint256 version) public view returns(address tempAddr) {
        require(_templates[tempName].addrs.length >= version, "non existing template address");
        tempAddr = _templates[tempName].addrs[version - 1];
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     *
     * This function overrides the ERC721 standard contract. There is no external link resource identifier for the tokens. 
     * All JSON files and images are generated on-chain from ChanceRoom instant data. The image is generated on a template 
     * that the creator selected before. All URIs are a base64 encoded string SVG code concatenated to variables.
     *
     * @param tokenId The token identifier.
     * @return A string representing the URI for the given token.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);

        address chanceRoomAddr = address(uint160(tokenId));
        IChanceRoom chr = IChanceRoom(chanceRoomAddr);

        (string memory _name, string memory _rule) = chr.info();
        (string memory status1, string memory status2) = chr.status();

        return string.concat('data:application/json;base64,', Base64.encode(abi.encodePacked(
              '{"name": "#', _name, 
            '", "description": "', _rule,
            '", "status": "', string.concat(status1, "_", status2),
            '", "image": "', image(chanceRoomAddr, status1, status2), '"}'
            ))
        );
    } 

    /**
     * @dev Generates the image for the given `chanceRoomAddr`, `status1` and `status2`.
     *
     * @param chanceRoomAddr The address of the ChanceRoom instance.
     * @param status1 The first status string.
     * @param status2 The second status string.
     * @return A string representing the generated image.
     */
    function image(
        address chanceRoomAddr,
        string memory status1, 
        string memory status2
    ) internal view returns (string memory) {

        IChanceRoom chr = IChanceRoom(chanceRoomAddr);

        uint256 implVersion = chanceRoomVersion[chanceRoomAddr];

        (string memory tempName, address tempAddr) = chr.template();
        (string memory nftName, address nftAddr, uint256 nftId) = chr.nft();
        (string memory implName, address implAddr) = chr.implInfo();

        return string.concat('data:image/svg+xml;base64,', Base64.encode(abi.encodePacked(
            _template({
                implementation : implName,
                implAddr : implAddr.toHexString(),
                implVersion : string.concat("V", implVersion.toString()),
                template : tempName,
                tempAddr : tempAddr.toHexString(),
                nftAddr : nftAddr.toHexString(),
                nft : string.concat(nftName, " : ", nftId.toString()),
                status1 : status1,
                status2 : status2
            })
        )));
    }

    /**
     * @dev Generates the SVG template string with the given parameters.
     *
     * @param implementation The implementation name.
     * @param implAddr The implementation address.
     * @param implVersion The implementation version.
     * @param template The template name.
     * @param tempAddr The template address.
     * @param nftAddr The NFT address.
     * @param nft The NFT name and identifier.
     * @param status1 The first status string.
     * @param status2 The second status string.
     * @return A string representing the generated SVG template.
     */
    function _template(
        string memory implementation,
        string memory implAddr,
        string memory implVersion,
        string memory template,
        string memory tempAddr,
        string memory nftAddr,
        string memory nft,
        string memory status1,
        string memory status2
    ) private pure returns(string memory) {
        return string.concat(
            '<?xml version="1.0" encoding="UTF-8" standalone="no"?><!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"><!-- Created with Vectornator (http://vectornator.io/) --><svg stroke-miterlimit="10" style="fill-rule:nonzero;clip-rule:evenodd;stroke-linecap:round;stroke-linejoin:round;" version="1.1" viewBox="0 0 800 800" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><defs><radialGradient cx="400" cy="400" gradientTransform="matrix(1 0 0 1 0 0)" gradientUnits="userSpaceOnUse" id="RadialGradient" r="230"><stop offset="0" stop-color="#ffffff"/><stop offset="1" stop-color="#00eeff"/></radialGradient><radialGradient cx="400" cy="400" gradientTransform="matrix(1 0 0 1 0 0)" gradientUnits="userSpaceOnUse" id="RadialGradient_2" r="551"><stop offset="0" stop-color="#ffffff"/><stop offset="1" stop-color="#00ffff"/></radialGradient><clipPath id="TextBounds"><rect height="57.1334" transform="matrix(1 -0 -0 1 -0.722273 -42.2787)" width="796.736" x="0.722273" y="42.2787"/></clipPath><clipPath id="TextBounds_2"><rect height="57.1334" transform="matrix(1 -0 -0 1 -1.63637 -89.2916)" width="796.736" x="1.63637" y="89.2916"/></clipPath><clipPath id="TextBounds_3"><rect height="57.1334" transform="matrix(1 -0 -0 1 -0.168591 -137.647)" width="796.736" x="0.168591" y="137.647"/></clipPath><clipPath id="TextBounds_4"><rect height="57.1334" transform="matrix(1 -0 -0 1 -2.70824 -204.539)" width="796.736" x="2.70824" y="204.539"/></clipPath><clipPath id="TextBounds_5"><rect height="57.1334" transform="matrix(1 -0 -0 1 -3.59365 -244.644)" width="796.736" x="3.59365" y="244.644"/></clipPath><clipPath id="TextBounds_6"><rect height="46.3086" transform="matrix(1 -0 -0 1 -44.7604 -347.213)" width="727.292" x="44.7604" y="347.213"/></clipPath><clipPath id="TextBounds_7"><rect height="46.3086" transform="matrix(1 -0 -0 1 -45.0721 -411.787)" width="727.292" x="45.0721" y="411.787"/></clipPath><clipPath id="TextBounds_8"><rect height="57.1334" transform="matrix(1 -0 -0 1 -50.2193 -586.498)" width="751.159" x="50.2193" y="586.498"/></clipPath><clipPath id="TextBounds_9"><rect height="57.1334" transform="matrix(1 -0 -0 1 -50.4114 -564.765)" width="748.649" x="50.4114" y="564.765"/></clipPath><clipPath id="TextBounds_10"><rect height="57.1334" transform="matrix(1 -0 -0 1 -44.6703 -649.476)" width="748.649" x="44.6703" y="649.476"/></clipPath><clipPath id="TextBounds_11"><rect height="57.1334" transform="matrix(1 -0 -0 1 -47.189 -673.213)" width="751.159" x="47.189" y="673.213"/></clipPath></defs><clipPath id="ArtboardFrame"><rect height="800" width="800" x="0" y="0"/></clipPath><g clip-path="url(#ArtboardFrame)" id="Untitled"><path d="M0 0L800 0L800 0L800 800L800 800L0 800L0 800L0 0L0 0Z" fill="#ffffff" fill-rule="evenodd" opacity="1" stroke="none"/><path d="M0 0L800 0L800 0L800 800L800 800L0 800L0 800L0 0L0 0Z" fill="url(#RadialGradient)" fill-rule="evenodd" opacity="1" stroke="none"/><path d="M998.7 439.2C1000.4 412.7 1000.4 386.5 998.8 360.7L401 399.9L401 399.8L988.6 282.9C983.5 257 976.7 231.7 968.3 207.1L400.9 399.7L400.9 399.6L938.2 134.6C926.6 111.1 913.4 88.4 898.9 66.7L400.8 399.5C400.8 399.5 400.8 399.4 400.7 399.4L851.1 4.4C833.8-15.3 815.3-33.8 795.6-51.1L400.6 399.3C400.6 399.3 400.5 399.3 400.5 399.2L733.4-99C711.7-113.5 689-126.6 665.4-138.3L400.4 399.1L400.3 399.1L592.9-168.3C568.3-176.6 543-183.4 517.1-188.5L400.2 399L400.1 399L439.3-198.7C412.8-200.4 386.6-200.4 360.8-198.8L399.9 399L399.8 399L282.9-188.6C257-183.5 231.7-176.7 207.1-168.3L399.7 399.1L399.6 399.1L134.6-138.2C111.1-126.6 88.4-113.4 66.7-98.9L399.5 399.2C399.5 399.2 399.4 399.2 399.4 399.3L4.4-51.1C-15.3-33.9-33.8-15.3-51.1 4.4L399.3 399.4C399.3 399.4 399.3 399.5 399.2 399.5L-99 66.6C-113.5 88.3-126.6 111-138.3 134.6L399.1 399.6L399.1 399.7L-168.3 207.1C-176.6 231.7-183.4 257-188.5 282.9L399 399.8L399 399.9L-198.7 360.7C-200.4 387.2-200.4 413.4-198.8 439.2L399 400.1L399 400.2L-188.6 517.1C-183.5 543-176.7 568.3-168.3 592.9L399.1 400.3L399.1 400.4L-138.2 665.4C-126.6 688.9-113.4 711.6-98.8999 733.3L399.2 400.5C399.2 400.5 399.2 400.6 399.3 400.6L-51.0999 795.6C-33.7999 815.3-15.2999 833.8 4.40007 851.1L399.4 400.7C399.4 400.7 399.5 400.7 399.5 400.8L66.6 899C88.3 913.5 111 926.6 134.6 938.3L399.6 400.9L399.7 400.9L207.1 968.3C231.7 976.6 257 983.4 282.9 988.5L399.8 401L399.9 401L360.7 998.7C387.2 1000.4 413.4 1000.4 439.2 998.8L400.1 401L400.2 401L517.1 988.6C543 983.5 568.3 976.7 592.9 968.3L400.3 400.9L400.4 400.9L665.4 938.2C688.9 926.6 711.6 913.4 733.3 898.9L400.5 400.8C400.5 400.8 400.6 400.8 400.6 400.7L795.6 851.1C815.3 833.8 833.8 815.3 851.1 795.6L400.7 400.6C400.7 400.6 400.7 400.5 400.8 400.5L899 733.4C913.5 711.7 926.6 689 938.3 665.4L400.9 400.4L400.9 400.3L968.3 592.9C976.6 568.3 983.4 543 988.5 517.1L401 400.2L401 400.1L998.7 439.2Z" fill="url(#RadialGradient_2)" fill-rule="evenodd" opacity="1" stroke="none"/><path d="M58.5067 316.954L757.39 316.954C766.919 316.954 774.643 324.828 774.643 334.541L774.643 478.406C774.643 488.12 766.919 495.994 757.39 495.994L58.5067 495.994C48.9777 495.994 41.2529 488.12 41.2529 478.406L41.2529 334.541C41.2529 324.828 48.9777 316.954 58.5067 316.954Z" fill="#000000" fill-opacity="0.7" fill-rule="evenodd" opacity="1" stroke="none"/><text clip-path="url(#TextBounds)" fill="#11055c" font-family="Arial-BoldMT" font-size="40" opacity="1" stroke="none" text-anchor="middle" transform="matrix(1 0 0 1 0.722273 42.2787)" x="0" y="0"><tspan x="398.368" y="36">',
            implementation,
            '</tspan></text><text clip-path="url(#TextBounds_2)" fill="#11055c" font-family="Arial-BoldMT" font-size="30" opacity="1" stroke="none" text-anchor="middle" transform="matrix(1 0 0 1 1.63637 89.2916)" x="0" y="0"><tspan x="398.368" y="27">',
            implVersion,
            '</tspan></text><text clip-path="url(#TextBounds_4)" fill="#11055c" font-family="Arial-BoldMT" font-size="25" opacity="1" stroke="none" text-anchor="middle" transform="matrix(1 0 0 1 2.70824 204.539)" x="0" y="0"><tspan x="398.368" y="23">',
            nft,
            '</tspan></text><text clip-path="url(#TextBounds_5)" fill="#11055c" font-family="Arial-BoldMT" font-size="15" opacity="1" stroke="none" text-anchor="middle" transform="matrix(1 0 0 1 3.59365 244.644)" x="0" y="0"><tspan x="400.452" y="14">Addr: ',
            nftAddr,
            '</tspan></text><text clip-path="url(#TextBounds_6)" fill="#ffffff" font-family="Arial-BoldMT" font-size="40" opacity="1" stroke="none" text-anchor="middle" transform="matrix(1 0 0 1 44.7604 347.213)" x="0" y="0"><tspan x="363.646" y="36">',
            status1,
            '</tspan></text><text clip-path="url(#TextBounds_7)" fill="#e1e1e1" font-family="Arial-BoldMT" font-size="40" opacity="1" stroke="none" text-anchor="middle" transform="matrix(1 0 0 1 45.0721 411.787)" x="0" y="0"><tspan x="363.646" y="36">',
            status2,
            '</tspan></text><text clip-path="url(#TextBounds_8)" fill="#11055c" font-family="ArialMT" font-size="15" opacity="1" stroke="none" text-anchor="middle" transform="matrix(1 0 0 1 50.2193 586.498)" x="0" y="0"><tspan x="205.148" y="14">Addr: ',
            tempAddr,
            '</tspan></text><text clip-path="url(#TextBounds_9)" fill="#11055c" font-family="Arial-BoldMT" font-size="15" opacity="1" stroke="none" text-anchor="start" transform="matrix(1 0 0 1 50.4114 564.765)" x="0" y="0"><tspan x="0" y="14">',
            template,
            '</tspan></text><text clip-path="url(#TextBounds_10)" fill="#11055c" font-family="Arial-BoldMT" font-size="15" opacity="1" stroke="none" text-anchor="start" transform="matrix(1 0 0 1 44.6703 649.476)" x="0" y="0"><tspan x="0" y="14">',
            implementation,
            '</tspan></text><text clip-path="url(#TextBounds_11)" fill="#11055c" font-family="ArialMT" font-size="15" opacity="1" stroke="none" text-anchor="middle" transform="matrix(1 0 0 1 47.189 673.213)" x="0" y="0"><tspan x="205.148" y="14">Addr: ',
            implAddr,
            '</tspan></text></g></svg>'
        );
    }
    /**
     * @dev Returns the power of an address, which is the number of leading zeros in the binary 
     * representation of the address.
     *
     * @param addr The address to calculate the power of.
     * @return The power of the address.
     */
    function power(address addr) public pure returns (uint256) {
        return addr.power();
    }

    /**
     * @dev Sets the minimum power required for an address to be considered valid.
     *
     * @param _minPower The new minimum power required.
     * 
     * Requirements:
     * 
     * - Only the owner of the contract is allowed to call this function.
     */
    function setMinPower(uint256 _minPower) public onlyOwner {
        minPower = _minPower;
    }


    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}