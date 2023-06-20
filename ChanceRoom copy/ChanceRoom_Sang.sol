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

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../utils/TemplateView.sol";
import "../utils/AppStorage.sol";
import "../utils/VRFConsumer.sol";
import "../utils/Swapper.sol";
import "../utils/OwnableFactory.sol";


/**
 * @dev ChanceRoom_Sang is a limited ticket and time chanceroom powered by lott-link
 * there is a valuable NFT locked by owner on this chanceroom and users can buy tickets in certain price
 * after the selling ended, the chanceroom rollups the chainlink RNC and by random one of tickets wins 
 * the NFT
 */
contract ChanceRoom_Sang is Initializable, OwnableFactory, TemplateView, ERC721Holder, ERC721Upgradeable, ERC721EnumerableUpgradeable, VRFConsumer, Swapper {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    string constant implName = "ChanceRoom_Sang";
    address immutable implAddr;

    event Refund(uint256 numTickets);
    event Rollup(address msgSender);

    constructor(IFactory chanceRoomFactory)
        OwnableFactory(chanceRoomFactory)
         initializer 
    {
        __ERC721_init_unchained("ChanceRoom_Sang", "CRS");
        implAddr = address(this);
    }

    /**
     * @dev Called once after chance room created
     * 
     * Requirements:
     * 
     * -only creator of the chance room can call this function
     */
    function initialize(
        string memory tempName,
        address _nftAddr,
        uint256 _nftId,
        uint256 _maximumTicket,
        uint256 _ticketPrice,
        uint256 holdingTime
    ) initializer onlyOwner public {
        __ERC721_init_unchained(
            string.concat("ChanceRoom_Sang on ", IERC721Metadata(_nftAddr).name(), " : ", _nftId.toString()), 
            "CRS"
        );
        (address tempAddr,) = ChanceRoomFactory.tempLatestVersion(tempName);
        AppStorage.layout().Address.tempAddr = tempAddr;
        AppStorage.layout().Address.nftAddr = _nftAddr;
        AppStorage.layout().Uint256.nftId = _nftId;
        AppStorage.layout().Uint256.maximumTicket = _maximumTicket;
        AppStorage.layout().Uint256.ticketPrice = _ticketPrice;
        AppStorage.layout().Uint256.deadLine = block.timestamp + holdingTime;
        IERC721(_nftAddr).transferFrom(msg.sender, address(this), _nftId);
        safeMint(address(this));
    }  


    /**
     * @dev Returns the app storage all data in one call.
     */
    function layout() public pure returns(AppStorage.Layout memory) {
        return AppStorage.layout();
    }

    /**
     * @dev Returns the current chain id.
     */
    function chainId() public view returns(uint256 id) {
        assembly{
            id := chainid()
        }
    }

    /**
     * @dev Returns the name, address and the id of the valuable NFT.
     */
    function lockedNFT() public view returns(
        string memory name,
        address addr, 
        uint256 id
    ) {
        addr = AppStorage.layout().Address.nftAddr;
        id = AppStorage.layout().Uint256.nftId;
        if(addr != address(0)) {
            name = IERC721Metadata(addr).name();
        }
    }

    /**
     * @dev Returns the name and address of the implementation of this chance room which cloned from.
     */
    function implementation() public view returns (
        string memory name,
        address addr
    ) {
        name = implName;
        addr = implAddr;
    }

    /**
     * @dev Returns the name and address of the template which the chanceroom uses.
     */
    function tempInfo() public view returns(
        string memory name,
        address addr
    ) {

        addr = AppStorage.layout().Address.tempAddr;
        if(addr != address(0)) {
            name = ITemplate(addr).name();
        }
    }

    /**
     * @dev Returns the name and the rule of this implementation.
     */
    function info() public view returns(
        string memory _name,
        string memory _rule,
        uint256 _initTime
    ) {
        _name = name();
        _rule = "SANG LOTTERY: A fixed and limited number of tickets will be sold to draw an NFT. Organizer will set the number of tickets, their price, and the deadline of the Sang Lottery at the beginning when She/He locks the price NFT in deployed SANG LOTTERY contract. If all the tickets have been sold before the deadline: Organizer can draw the winner, The NFT, and the organizer's money will transfer automatically. * before the deadline just the organizer can call the draw function but after that time everyone can call the draw function. If all the tickets are not sold before the deadline. Everyone can withdraw their money from the contracts and Organizer can release their NFT if all the tickets burned. Powered By Lott.Link";
    }

    /**
     * @dev Returns the constant ticket price.
     */
    function ticketPrice() public view returns(uint256 price) {
        price = AppStorage.layout().Uint256.ticketPrice;
    }

    /**
     * @dev Returns two strings that show status of the chance room.
     * for example `ticket selling` of `soldOut` are some statuses.
     */
    function status() public view returns(string memory s1, string memory s2) {
        AppStorage.Layout storage app = AppStorage.layout();

        uint256 timestamp = block.timestamp;

        if(app.Address.nftAddr != address(0)) {
            if(app.Uint256.soldTickets < AppStorage.layout().Uint256.maximumTicket) {
                if(timestamp < app.Uint256.deadLine) {
                    s1 = "Ticket selling";
                    uint256 remainTime = app.Uint256.deadLine - timestamp;
                    uint256 d = remainTime / 1 days;
                    remainTime %= 1 days;
                    uint256 h = remainTime / 1 hours;
                    remainTime %= 1 hours;
                    uint256 m = remainTime / 1 minutes + 1;
                    s2 = string.concat("remaining: ", d.toString(), "d : ", h.toString(), "h : ", m.toString(), "m");
                } else {
                    s1 = "deadline executed";
                    if(!AppStorage.layout().Bool.refunded) {
                        s2 = "Waiting for refund call";
                    } else {
                        s2 = "refunded";
                    }
                }
            } else {
                s1 = "soldout";
                if(!app.Bool.rolledup) {
                    s2 = "Waiting for roll up";
                } else if(app.Uint256.winnerId == 0) {
                    s2 = "Waiting for ChainLink";
                } else {
                    s2 = "Winner selected";
                }
            } 
        } else {
            s1 = "non initialized";
        }
    }


    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     * 
     * This is an overrided function from the ERC721 standard contract. there is no external link
     * resource identifier for the tokens. all jason files and images are generated onchain from 
     * the ticket instance data
     * 
     * the image is generated on a template which the creator selected before. all the uri is a 
     * base64 encoded string svg code concatenated to variables.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        if(tokenId == 0) {
            return IERC721Metadata(AppStorage.layout().Address.nftAddr).tokenURI(AppStorage.layout().Uint256.nftId);
        }
        AppStorage.layout().Address.tempAddr;
        (
            string memory _name, 
            string memory _rule
        ) = info();
        (
            string memory s1, 
            string memory s2
        ) = status();

        return string.concat('data:application/json;base64,', Base64.encode(abi.encodePacked(
              '{"name": "#', tokenId.toString(), 
            '", "description": "', string.concat(_name, " ", _rule),
            '", "status": "', string.concat(s1, "_", s2),
            '", "image": "', _image(AppStorage.layout().Address.tempAddr, tokenId), '"'
            ))
        );
    }

    
    /**
     * @dev Changes the template used by the chance room.
     * 
     * Requirements:
     * 
     * - the template must be verified in the chanceRoomFactory.
     * - only owner of the contract is allowed to call this function.
     */
    function changeTemplate(string memory tempName) public onlyOwner {
        (address tempAddr,) = ChanceRoomFactory.tempLatestVersion(tempName);
        AppStorage.layout().Address.tempAddr = tempAddr;
    }

    /**
     * @dev Buys the ticket and transfers to the buyer wallet address.
     * 
     * Requirements:
     * 
     * - the chance room must be working and not ended.
     * - tickets must be not sold out.
     * - user must provide the ticket price.
     */
    function purchaseTicket() public payable {
        require(AppStorage.layout().Uint256.winnerId == 0, "ChanceRoom expired");
        require(totalSupply() < AppStorage.layout().Uint256.maximumTicket, "tickets soldOut");
        require(msg.value >= AppStorage.layout().Uint256.ticketPrice, "insufficient fee");
        require(
            block.timestamp < AppStorage.layout().Uint256.deadLine,
            "time limit has reached"
        );
        safeMint(msg.sender);
        AppStorage.layout().Uint256.soldTickets ++;
    }

    /**
     * @dev Rollups the random number consumer to generate a random.
     * 
     * Requirements:
     * 
     * - tickets must be sold out.
     */
    function rollup() public {
        require(
            totalSupply() == AppStorage.layout().Uint256.maximumTicket, 
            "tickets are not full sold"
        );
        require(
            AppStorage.layout().Bool.refunded == false,
            "This chance room has refunded"
        );

        AppStorage.layout().Bool.rolledup = true;
        if(chainId() == 137) {
            if(LINK.balanceOf(address(this)) < linkFee){
                swap_MATIC_LINK677(linkFee, 10 ** 17);
            }
            _getRandomNumber();
        } else {
            _select(block.timestamp);
        }

        emit Rollup(msg.sender);
    }

    function refund() public {
        uint256 numTickets = totalSupply();
        require(
            AppStorage.layout().Bool.rolledup == false,
            "This chance room has rolledup before"
        );
        require(
            block.timestamp >= AppStorage.layout().Uint256.deadLine,
            "refund time has not reached"
        );
        require(
            numTickets < AppStorage.layout().Uint256.maximumTicket, 
            "tickets has sold out"
        );

        address payable user;
        uint256 _ticketPrice = AppStorage.layout().Uint256.ticketPrice;
        for(uint256 i = 1; i < numTickets; i++) {
            user = payable(ownerOf(i));
            user.transfer(_ticketPrice);
        }
        IERC721(AppStorage.layout().Address.nftAddr).safeTransferFrom(address(this), owner(), AppStorage.layout().Uint256.nftId);
        AppStorage.layout().Bool.refunded = true;
        emit Refund(numTickets);
    }

    function safeMint(address to) internal {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
    }

    /**
     * @dev returns the random number and selects the winner.
     * 
     * Only chainlink RNC can call this function
     */
    function _select(uint256 randomness) internal override {

        uint256 denom = totalSupply();

        uint256 randIndex = randomness % denom + 1;

        address winner = ownerOf(randIndex);
        AppStorage.layout().Uint256.winnerId = randIndex;
        IERC721(AppStorage.layout().Address.nftAddr).safeTransferFrom(address(this), winner, AppStorage.layout().Uint256.nftId);
        payable(owner()).transfer(address(this).balance);
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