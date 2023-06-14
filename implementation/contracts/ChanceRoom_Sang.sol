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
import "./interfaces/IChanceRoom.sol";
import "./utils/TemplateView.sol";
import "./utils/AppStorage.sol";
import "./utils/VRFConsumer.sol";
import "./utils/Swapper.sol";
import "./utils/OwnableFactory.sol";


/**
 * @title ChanceRoom_Sang
 * @notice A limited ticket and time chanceroom powered by Lott-link.
 * @notice Users can buy tickets at a certain price to enter the chanceroom for a chance to win a valuable NFT locked by the owner.
 * @notice After the selling period ends, the chanceroom triggers the Chainlink RNC to randomly select a winning ticket.
 * @dev This contract is implemented using the Lott-link API and Chainlink RNC to ensure a fair and secure chanceroom.
 */
contract ChanceRoom_Sang is IChanceRoom, Initializable, OwnableFactory, TemplateView, ERC721Holder, ERC721Upgradeable, ERC721EnumerableUpgradeable, VRFConsumer, Swapper {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    string constant implName = "Sang";
    address immutable implAddr;

    event Refund(uint256 numTickets);
    event Trigger(address msgSender, bytes32 requestId);

    /**
     * @dev Constructor function for the ChanceRoom contract.
     * @param chanceRoomFactory the address of the factory that creates instances of ChanceRoom contracts.
     * This contract inherits from OwnableFactory, which provides ownership functions to control access to the contract.
     * The implementation address of the ChanceRoom contract is set to the address of this contract.
    */
    constructor(IFactory chanceRoomFactory)
        OwnableFactory(chanceRoomFactory)
    {
        implAddr = address(this);
    }
    
    /**
     * @dev Initializes a new chance room with specified parameters.
     * 
     * @param _tempName_ The name of the chance room template used to create this chance room.
     * @param _nftAddr_ The address of the NFT locked by the owner on this chance room.
     * @param _nftId_ The ID of the NFT locked by the owner on this chance room.
     * @param _maximumTicket_ The maximum number of tickets that can be purchased in this chance room.
     * @param _ticketPrice_ The price of each ticket in this chance room.
     * @param _holdingTime_ The holding time in seconds after which the chance room is closed for ticket purchase.
     * 
     * Requirements:
     * 
     *  - Only the creator of the chance room can call this function.
     */
    function initialize(
        string memory _tempName_,
        address _nftAddr_,
        uint256 _nftId_,
        uint256 _maximumTicket_,
        uint256 _ticketPrice_,
        uint256 _holdingTime_
    ) initializer onlyOwner public {
        // Set chance room name as concatenation of the NFT name and ID.
        __ERC721_init_unchained(
            string.concat("ChanceRoom_Sang on ", IERC721Metadata(_nftAddr_).name(), " : ", _nftId_.toString()), 
            "CRS"
        );
        (address tempAddr,) = ChanceRoomFactory.tempLatestVersion(_tempName_);
        AppStorage.layout().Uint256.initTime = block.timestamp;
        AppStorage.layout().Uint256.deadLine = block.timestamp + _holdingTime_;
        AppStorage.layout().Address.tempAddr = tempAddr;
        AppStorage.layout().Address.nftAddr = _nftAddr_;
        AppStorage.layout().Uint256.nftId = _nftId_;
        AppStorage.layout().Uint256.maximumTicket = _maximumTicket_;
        AppStorage.layout().Uint256.ticketPrice = _ticketPrice_;
        IERC721(_nftAddr_).transferFrom(msg.sender, address(this), _nftId_);
        safeMint(address(this));
    }

    /**
     * @dev Returns the AppStorage struct which contains all the contract's data in a single call.
     * @notice This function is view only and does not modify any state variables.
     * @notice The returned struct cannot be modified by the caller.
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
     * @dev Returns the name, address and the id of the valuable NFT associated with the ChanceRoom.
     * @return name - the name of the NFT.
     * @return addr - the address of the NFT contract.
     * @return id - the id of the NFT.
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
     * @dev Returns the name and address of the implementation contract that this chance room was cloned from.
     * @return name The name of the implementation contract.
     * @return addr The address of the implementation contract.
     */
    function implInfo() public view returns (
        string memory name,
        address addr
    ) {
        name = implName;
        addr = implAddr;
    }

    /**
     * @dev Returns the name and address of the template that this chance room uses.
     *
     * Requirements:
     *
     * - The address of the template must not be zero.
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
     * 
     * @return _name The name of this implementation.
     * @return _rule The rule of this implementation, which describes the Sang Lottery process for selling tickets and drawing an NFT.
     */
    function info() public view returns(
        string memory _name,
        string memory _rule,
        uint256 _initTime
    ) {
        _name = name();
        _rule = "Sang Lottery: A fixed and limited number of tickets will be sold to draw an NFT. Organizer sets the number of tickets, their price, and the deadline of the Sang Lottery at the beginning when they lock the prized NFT in the deployed SANG LOTTERY contract. If all the tickets are sold before the deadline, the Organizer can draw the winner, the NFT, and the Organizer's prize money will transfer automatically. Before the deadline, only the Organizer can call the draw function, but after the deadline, anyone can call the draw function. If all the tickets are not sold before the deadline, everyone can withdraw their money from the contract and the Organizer can release their NFT if all the tickets were burned. Powered By Lott.Link.";
        _initTime = AppStorage.layout().Uint256.initTime;
    }

    /**
     * @dev Returns the constant ticket price of the chanceroom.
     * 
     * @return The ticket price in uint256.
     */
    function ticketPrice() public view returns(uint256) {
        return AppStorage.layout().Uint256.ticketPrice;
    } 

    /**
     * @dev Returns two strings that show the current status of the chance room.
     * @return s1 A string indicating the overall status of the chance room.
     * @return s2 A string indicating additional details about the current status.
     *         For example, 'ticket selling' or 'sold out' are some possible values for s1.
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
                    s2 = string.concat("Remaining: ", d.toString(), "d : ", h.toString(), "h : ", m.toString(), "m");
                } else {
                    s1 = "Deadline executed";
                    if(!AppStorage.layout().Bool.refunded) {
                        s2 = "Waiting for refund call";
                    } else {
                        s2 = "Refunded";
                    }
                }
            } else {
                s1 = "Sold out";
                if(!app.Bool.triggered) {
                    s2 = "Waiting for roll up";
                } else if(app.Uint256.winnerId == 0) {
                    s2 = "Waiting for ChainLink";
                } else {
                    s2 = "Winner selected";
                }
            } 
        } else {
            s1 = "Not initialized";
        }
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     *
     * This function is overridden from the ERC721 standard contract. There is no external link 
     * resource identifier for the tokens, all JSON files and images are generated on-chain from 
     * the ticket instance data.
     * 
     * The image is generated on a template which the creator selected before. All the URI is a 
     * Base64 encoded string SVG code concatenated to variables.
     *
     * @param tokenId The ID of the token for which the URI is generated.
     * @return A string representing the URI for `tokenId`.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        if(tokenId == 0) {
            return IERC721Metadata(AppStorage.layout().Address.nftAddr).tokenURI(AppStorage.layout().Uint256.nftId);
        }
        AppStorage.Layout storage app = AppStorage.layout();
        (
            string memory _name, 
            string memory _rule,
            
        ) = info();
        (
            string memory s1, 
            string memory s2
        ) = status();
    
        return string.concat('data:application/json;base64,', Base64.encode(abi.encodePacked(
            '{"name": "#', tokenId.toString(),
            '", "description": "', string.concat(_name, " ", _rule),
            '", "status": "', string.concat(s1, "_", s2),
            '", "image": "', _image(app.Address.tempAddr, tokenId), '"}'
        )));
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
        require(totalSupply() <= AppStorage.layout().Uint256.maximumTicket, "tickets soldOut");
        require(msg.value >= AppStorage.layout().Uint256.ticketPrice, "insufficient fee");
        require(
            block.timestamp < AppStorage.layout().Uint256.deadLine,
            "time limit has reached"
        );
        safeMint(msg.sender);
        AppStorage.layout().Uint256.soldTickets ++;
    }

    /**
     * @dev Triggers the random number consumer to generate a random.
     * 
     * Requirements:
     * 
     * - tickets must be sold out.
     */
    function trigger() public {
        require(
            totalSupply() > AppStorage.layout().Uint256.maximumTicket, 
            "tickets are not full sold"
        );
        require(
            AppStorage.layout().Bool.refunded == false,
            "This chance room has refunded"
        );

        AppStorage.layout().Bool.triggered = true;
        bytes32 requestId;
        if(chainId() == 137) {
            if(LINK.balanceOf(address(this)) < linkFee){
                swap_MATIC_LINK677(linkFee, 10 ** 17);
            }
            requestId = _getRandomNumber();
        } else {
            _select(block.timestamp);
        }

        emit Trigger(msg.sender, requestId);
    }

    /**
     * @dev Allows the contract owner to refund all purchased tickets if certain conditions are met.
     * The function checks if the chance room has not triggered before, if the refund time has been reached,
     * and if all tickets have not been sold out. If the conditions are met, the function refunds all ticket buyers
     * by transferring the ticket price back to their wallets and transfers the NFT to the contract owner.
     * Finally, the refunded flag is set to true and the Refund event is emitted.
     * 
     * Requirements:
     * 
     * - The chance room has not triggered before.
     * - The refund time has been reached.
     * - All tickets have not been sold out.
     * 
     * Emits a {Refund} event indicating the number of refunded tickets.
     */
    function refund() public {
        uint256 numTickets = totalSupply();
        require(
            AppStorage.layout().Bool.triggered == false,
            "This chance room has triggered before"
        );
        require(
            block.timestamp >= AppStorage.layout().Uint256.deadLine,
            "refund time has not reached"
        );
        require(
            numTickets <= AppStorage.layout().Uint256.maximumTicket, 
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
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _tokenIdCounter.increment();
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
        override(ERC721EnumerableUpgradeable, ERC721Upgradeable, IERC165)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}