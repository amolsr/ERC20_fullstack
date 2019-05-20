#!/usr/bin/env bash

C_RED="\033[31;01m"
C_GREEN="\033[32;01m"
C_YELLOW="\033[33;01m"
C_BLUE="\033[34;01m"
C_PINK="\033[35;01m"
C_CYAN="\033[36;01m"
C_NO="\033[0m"

LANGUAGE=${1:-"golang"}
CC_SRC_PATH=github.com/chaincode/ERC20/chaincode
set -e

################################################################################
###                                FUNCTIONS                                 ###
################################################################################

function up {
	docker-compose -f ./docker-compose.yml down
	docker-compose -f ./docker-compose.yml up -d ca.example.com orderer.example.com peer0.MEDSOS.example.com  peer0.HSLU.example.com couchdb peer1.MEDSOS.example.com api.MEDSOS.example.com cli webservices
	
	export FABRIC_START_TIMEOUT=10
	sleep ${FABRIC_START_TIMEOUT}
}

function createChannel {

	echo "0";
	docker exec \
		-e "CORE_PEER_LOCALMSPID=MEDSOSMSP" \
		-e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@MEDSOS.example.com/msp" peer0.MEDSOS.example.com peer channel create \
		-o orderer.example.com:7050 \
		-c ptwist \
		-f /etc/hyperledger/configtx/channel.tx

}

function addPeers {
	
	echo "1";
	docker exec \
		-e "CORE_PEER_LOCALMSPID=MEDSOSMSP" \
		-e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@MEDSOS.example.com/msp" peer0.MEDSOS.example.com peer channel join \
		-b ptwist.block


	echo "2";
	docker exec \
		-e "CORE_PEER_LOCALMSPID=MEDSOSMSP" \
		-e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@MEDSOS.example.com/msp" peer1.MEDSOS.example.com peer channel join \
		-b ptwist.block


	echo "3";
	docker exec \
		-e "CORE_PEER_LOCALMSPID=MEDSOSMSP" \
		-e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@MEDSOS.example.com/msp" peer0.MEDSOS.example.com peer channel update \
		-o orderer.example.com:7050 \
		-c ptwist \
		-f /etc/hyperledger/configtx/MEDSOSMSPanchors.tx




	echo "4";
	docker exec \
		-e "CORE_PEER_LOCALMSPID=HSLUMSP" \
		-e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@HSLU.example.com/msp" peer0.HSLU.example.com peer channel join \
		-b ptwist.block


	echo "5";
	docker exec \
		-e "CORE_PEER_LOCALMSPID=HSLUMSP" \
		-e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@HSLU.example.com/msp" peer0.HSLU.example.com peer channel update \
		-o orderer.example.com:7050 \
		-c ptwist \
		-f /etc/hyperledger/configtx/HSLUPanchors.tx

}

################################################################################
###                                   MAIN                                   ###
################################################################################

up
createChannel
addPeers
