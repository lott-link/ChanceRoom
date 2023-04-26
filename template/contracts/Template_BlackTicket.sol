// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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

import "./utils/AppStorage.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "./interfaces/ITemplate.sol";


contract Template_BlackTicket is ITemplate, ERC165 {
    using Strings for *;

    function name() external pure returns (string memory){
        return "BlackTicket";
    }

    function image(uint256 tokenId) external view returns (string memory) {
        AppStorage.Layout storage app = AppStorage.layout();

        (,bytes memory res) = msg.sender.staticcall(abi.encodeWithSignature("status()"));
        (string memory state1, string memory state2) = abi.decode(res, (string, string));

        return string.concat('data:image/svg+xml;base64,', Base64.encode(abi.encodePacked(
            _template({
                timestamp : block.timestamp.toString(),
                ticketId : tokenId.toString(),
                maximumTicket : app.Uint256.maximumTicket.toString(),
                soldTickets : app.Uint256.soldTickets.toString(),
                nftContract : address(app.Address.nftAddr).toHexString(),
                nftId : app.Uint256.nftId.toString(),
                nftName : IERC721Metadata(app.Address.nftAddr).name(),
                winnerId : app.Uint256.winnerId == 0 ? "?" : app.Uint256.winnerId.toString(),
                state1 : state1,
                state2 : state2
            })
        )));
    }

    function _template(
        string memory timestamp,
        string memory ticketId,
        string memory maximumTicket,
        string memory soldTickets,
        string memory nftContract,
        string memory nftId,
        string memory nftName,
        string memory winnerId,
        string memory state1,
        string memory state2
    ) private pure returns(string memory) {      
        return string.concat(
            '<svg stroke-miterlimit="10" style="fill-rule:nonzero;clip-rule:evenodd;stroke-linecap:round;stroke-linejoin:round" viewBox="0 0 1920 1080" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"><defs><clipPath id="b"><path transform="translate(-448.393 -333.662)" d="M448.393 333.662H1103.2v116.271H448.393z"/></clipPath><clipPath id="c"><path transform="translate(-545.03 -448.7)" d="M545.03 448.7h475.123v23.546H545.03z"/></clipPath><clipPath id="d"><path transform="translate(-28.85 -1039.14)" d="M28.85 1039.14h736.212v23.654H28.85z"/></clipPath><clipPath id="e"><path transform="translate(-371.194 -674.582)" d="M371.194 674.582h137.288v53.472H371.194z"/></clipPath><clipPath id="f"><path transform="translate(-364.32 -628.047)" d="M364.32 628.047h120.91v21.589H364.32z"/></clipPath><clipPath id="g"><path transform="translate(-516.959 -674.363)" d="M516.959 674.363h137.288v53.472H516.959z"/></clipPath><clipPath id="h"><path transform="translate(-517.225 -629.349)" d="M517.225 629.349h120.91v21.589h-120.91z"/></clipPath><clipPath id="i"><path transform="translate(-672.878 -631.677)" d="M672.878 631.677h141.284v32.357H672.878z"/></clipPath><clipPath id="j"><path transform="translate(-675.367 -672.748)" d="M675.367 672.748h137.288v53.472H675.367z"/></clipPath><clipPath id="k"><path transform="translate(-896.285 -628.011)" d="M896.285 628.011h258.567v53.472H896.285z"/></clipPath><clipPath id="l"><path transform="translate(-896.285 -695.736)" d="M896.285 695.736h290.834v15.42H896.285z"/></clipPath><clipPath id="m"><path transform="translate(-896.285 -729.689)" d="M896.285 729.689h290.834v15.42H896.285z"/></clipPath><clipPath id="n"><path transform="translate(-896.285 -679.995)" d="M896.285 679.995h290.834v15.42H896.285z"/></clipPath><clipPath id="o"><path transform="translate(-896.285 -713.764)" d="M896.285 713.764h290.834v15.42H896.285z"/></clipPath><clipPath id="p"><path transform="rotate(90 1130.543 -461.747)" d="M1592.29 531.508h53.472v137.288h-53.472z"/></clipPath><clipPath id="q"><path transform="rotate(90 1112.947 -433.343)" d="M1546.29 558.695h21.589v120.91h-21.589z"/></clipPath><clipPath id="r"><path transform="rotate(90 1057.55 -534.52)" d="M1592.07 385.743h53.472v137.288h-53.472z"/></clipPath><clipPath id="s"><path transform="rotate(90 1040.207 -505.333)" d="M1545.54 370.997h40.71v163.878h-40.71z"/></clipPath><clipPath id="t"><path transform="rotate(90 1127.697 -304.003)" d="M1431.7 252.818h68.963v570.876H1431.7z"/></clipPath><filter color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="712.381" id="a" width="1580.66" x="187.405" y="210.235"><feDropShadow dx="25.357" dy="54.379" flood-color="#909090" flood-opacity=".333" in="SourceGraphic" result="Shadow" stdDeviation="5"/></filter></defs><path d="M0 0h1920v1080H0V0Z" fill="#c4c4c4" fill-rule="evenodd"/><g fill="#008bd2" fill-rule="evenodd"><path d="m1850.25 918.99-36.92-21.32a20.401 20.401 0 0 0-20.39 0l-36.92 21.32a20.381 20.381 0 0 0-10.2 17.65v42.64c0 7.28 3.89 14.01 10.19 17.66l36.92 21.32a20.401 20.401 0 0 0 20.39 0l36.92-21.32a20.376 20.376 0 0 0 10.19-17.66v-42.64a20.32 20.32 0 0 0-10.18-17.65Zm-47.11 89.24c-27.76 0-50.27-22.51-50.27-50.27s22.5-50.27 50.27-50.27c27.77 0 50.27 22.51 50.27 50.27s-22.51 50.27-50.27 50.27Z"/><path d="M1825.88 931.72h-12.67v13.01h-27.14v-13.01h-12.67v13.01h-9.44v12.63h9.44v15.29c0 4.19.98 7.36 2.94 9.5 1.96 2.14 5.03 3.21 9.22 3.21h21.89v-12.21h-18.66c-.89 0-1.57-.32-2.03-.95-.46-.63-.69-1.53-.69-2.7v-12.14h27.14v15.29c0 4.19.98 7.36 2.94 9.5 1.96 2.14 5.03 3.21 9.22 3.21h12.95v-12.21h-9.71c-.89 0-1.57-.32-2.03-.95-.46-.63-.69-1.53-.69-2.7v-12.14h12.44v-12.63h-12.45v-13.01Z"/></g><g fill-rule="evenodd"><path d="M187.405 210.235v648.003H1317.54c-.42-1.344-1.44-2.345-1.44-3.835 0-7.582 5.66-13.744 12.78-13.743 7.12 0 12.95 6.161 12.95 13.743 0 1.482-1.03 2.498-1.44 3.835h392.32V210.235h-393.6c.19.941.96 1.555.96 2.557 0 7.582-5.83 13.743-12.95 13.743-7.11 0-12.78-6.161-12.78-13.743 0-1.008.76-1.611.96-2.557H187.405Z" fill="#f9f9f9" filter="url(#a)"/><path d="M1088.87 845.387v8.219h227.31c.01-3.17 1.3-5.982 3.19-8.219h-230.5Zm249.62 0c1.89 2.237 3.17 5.049 3.19 8.219h391v-8.219h-394.19ZM187.361 829.567H1687.36v8.195H187.361v-8.195ZM588.639 811.9h600.001v8.195H588.639V811.9ZM187.394 211.056h280v8.196h-280v-8.196ZM187.405 231.661H1732.7v8.195H187.405v-8.195ZM1362.84 216.005h370v8.195h-370v-8.195ZM187.161 248.298h630v8.195h-630v-8.195Z"/><path d="m1328.19 225.32 1.44 615.332" fill="#f9f9f9" stroke="#000" stroke-dasharray="10.0,5.0" stroke-linecap="butt" stroke-width="4"/></g><g fill-rule="evenodd"><path d="M187.994 266.459h62v8.196h-62v-8.196ZM219.994 522.159h30v8.195h-30v-8.195ZM187.994 329.265h62v8.195h-62v-8.195ZM187.994 409.298h62v8.195h-62v-8.195ZM187.994 449.729h62v8.196h-62v-8.196ZM187.994 582.715h62v8.195h-62v-8.195ZM187.994 673.848h62v8.196h-62v-8.196ZM187.994 690.584h62v8.195h-62v-8.195ZM187.994 722.894h62v8.196h-62v-8.196ZM209.994 461.583h40v8.196h-40v-8.196ZM209.994 702.589h40v8.195h-40v-8.195ZM187.994 540h62v8.195h-62V540ZM187.994 507.351h62v8.195h-62v-8.195ZM187.994 362.8h62v8.196h-62V362.8ZM187.994 430.38h62v8.195h-62v-8.195ZM194.994 343.044h55v8.195h-55v-8.195ZM194.994 391.53h55v8.195h-55v-8.195ZM187.994 557.67h62v8.195h-62v-8.195ZM187.994 610.592h62v8.195h-62v-8.195ZM209.994 744.12h40v8.195h-40v-8.195ZM219.994 638.559h30v8.196h-30v-8.196Z"/></g><g fill-rule="evenodd"><path d="M1275.3 301.464H1380.3v8.195h-105v-8.195ZM1275.3 737.364h105v8.195h-105v-8.195ZM1275.3 752.885h105v8.196h-105v-8.196ZM1275.3 471.866h105v8.196h-105v-8.196ZM1275.3 409.581h105v8.196h-105v-8.196ZM1275.3 719.159h105v8.195h-105v-8.195ZM1275.3 690.881h105v8.196h-105v-8.196ZM1275.3 679.142h105v8.195h-105v-8.195ZM1275.3 657.305h105v8.195h-105v-8.195ZM1275.3 618.124h105v8.195h-105v-8.195ZM1275.3 540h105v8.195h-105V540ZM1275.3 581.545h105v8.196h-105v-8.196ZM1275.3 511.316h105v8.195h-105v-8.195ZM1275.3 450.84h105v8.196h-105v-8.196ZM1275.3 380.704h105v8.196h-105v-8.196ZM1275.3 321.415h105v8.195h-105v-8.195ZM1275.3 284.98h105v8.196h-105v-8.196ZM1275.3 633.355h105v8.195h-105v-8.195ZM1275.3 343.112h105v8.195h-105v-8.195ZM1275.3 599.412h105v8.196h-105v-8.196ZM1275.3 485.638h105v8.195h-105v-8.195ZM1275.3 363.792h105v8.195h-105v-8.195Z"/></g><g fill-rule="evenodd"><path d="M1697.38 290.501h35v8.195h-35v-8.195ZM1697.38 366.428h35v8.195h-35v-8.195ZM1697.38 395.751h35v8.196h-35v-8.196ZM1697.38 462.609h35v8.196h-35v-8.196ZM1697.38 507.838h35v8.196h-35v-8.196ZM1697.38 552.769h35v8.195h-35v-8.195ZM1697.38 634.892h35v8.195h-35v-8.195ZM1697.38 654.012h35v8.195h-35v-8.195ZM1697.38 674.478h35v8.195h-35v-8.195ZM1697.38 726.441h35v8.195h-35v-8.195ZM1697.38 746.927h35v8.195h-35v-8.195Z"/></g><g font-family="ArialMT"><text clip-path="url(#b)" font-size="100" transform="translate(448.393 333.662)"><tspan textLength="611.426" x="0" y="91">ChanceRoom</tspan></text><text clip-path="url(#c)" font-size="20" transform="translate(545.03 448.7)"><tspan textLength="426.455" x="0" y="18">NFT Lottery By lott link - Powered By Chain link </tspan></text></g><text clip-path="url(#d)" font-family="ArialMT" font-size="20" transform="translate(28.85 1039.14)"><tspan textLength="423.584" x="0" y="18">TokenURI Generation Timestamp : ',
            timestamp,
            '</tspan></text><path d="M394.548 662.224h377.899c28.195 0 51.051 7.874 51.051 17.587v39.406c0 9.713-22.856 17.587-51.051 17.587H394.548c-28.194 0-51.05-7.874-51.05-17.587v-39.406c0-9.713 22.856-17.587 51.05-17.587Z" fill="none" stroke="#000" stroke-linecap="butt" stroke-linejoin="bevel" stroke-width="4"/><text clip-path="url(#e)" font-family="ArialMT" font-size="45" transform="translate(371.194 674.582)"><tspan textLength="100.107" x="0" y="41">',
            ticketId,
            '</tspan></text><text clip-path="url(#f)" font-family="ArialMT" font-size="18" transform="translate(364.32 628.047)"><tspan textLength="116.358" x="0" y="16">Ticket Number</tspan></text><path d="M498.283 662.849s-10.203 41.54 2.447 72.582" fill="none" stroke="#000" stroke-width="4"/><text clip-path="url(#g)" font-family="ArialMT" font-size="45" transform="translate(516.959 674.363)"><tspan textLength="100.107" x="0" y="41">',
            maximumTicket,
            '</tspan></text><text clip-path="url(#h)" font-family="ArialMT" font-size="18" transform="translate(517.225 629.349)"><tspan textLength="99.035" x="0" y="16">Total Tickets</tspan></text><path d="M653.541 662.037s-10.202 41.541 2.447 72.582" fill="none" stroke="#000" stroke-width="4"/><text clip-path="url(#i)" font-family="ArialMT" font-size="18" transform="translate(672.878 631.677)"><tspan textLength="122.054" x="0" y="16">Number of sold</tspan></text><text clip-path="url(#j)" font-family="ArialMT" font-size="45" transform="translate(675.367 672.748)"><tspan textLength="100.107" x="0" y="41">',
            soldTickets,
            '</tspan></text><g font-family="ArialMT"><text clip-path="url(#k)" font-size="45" transform="translate(896.285 628.011)"><tspan textLength="245.083" x="0" y="41">Locked NFT</tspan></text><text clip-path="url(#l)" font-size="12" transform="translate(896.285 695.736)"><tspan textLength="280.898" x="0" y="11">',
            nftContract,
            '</tspan></text><text clip-path="url(#m)" font-size="12" transform="translate(896.285 729.689)"><tspan textLength="26.695" x="0" y="11">',
            nftId,
            '</tspan></text><text clip-path="url(#n)" font-size="12" transform="translate(896.285 679.995)"><tspan x="0" y="11">',
            nftName,
            '</tspan></text><text clip-path="url(#o)" font-size="12" transform="translate(896.285 713.764)"><tspan textLength="47.355" x="0" y="11">Token ID</tspan></text></g><path d="M1578.99 669.157v-244.06c0-18.209 7.87-32.97 17.59-32.97h39.4c9.71 0 17.59 14.761 17.59 32.97v244.06c0 18.208-7.88 32.97-17.59 32.97h-39.4c-9.72 0-17.59-14.762-17.59-32.97Z" fill="none" stroke="#000" stroke-linecap="butt" stroke-linejoin="bevel" stroke-width="4"/><text clip-path="url(#p)" font-family="ArialMT" font-size="45" transform="rotate(-90 1130.543 -461.747)"><tspan textLength="100.107" x="0" y="41">',
            ticketId,
            '</tspan></text><text clip-path="url(#q)" font-family="ArialMT" font-size="18" transform="rotate(-90 1112.947 -433.343)"><tspan textLength="116.358" x="0" y="16">Ticket Number</tspan></text><path d="M1580.55 541.707s41.54 10.203 72.59-2.447" fill="none" stroke="#000" stroke-width="4"/><text clip-path="url(#r)" font-family="ArialMT" font-size="45" transform="rotate(-90 1057.55 -534.52)"><tspan textLength="100.107" x="0" y="41">',
            winnerId,
            '</tspan></text><text clip-path="url(#s)" font-family="ArialMT" font-size="18" transform="rotate(-90 1040.208 -505.333)"><tspan textLength="126.035" x="0" y="16">Winner Number</tspan></text><text clip-path="url(#t)" font-family="ArialMT" font-size="30" text-anchor="middle" transform="rotate(-90 1127.697 -304.004)"><tspan x="285.438" y="27">',
            state1,
            '</tspan><tspan x="285.438" y="61">',
            state2,
            '</tspan></text></svg>'
        );
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(ITemplate).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}