import { LightningElement } from 'lwc';
import getAllData from '@salesforce/apex/MetaDataComponentChangeCont.getSubmitData';
import Meta_Morphing_Monitor from '@salesforce/label/c.Meta_Morphing_Monitor';
import Submit from '@salesforce/label/c.Submit';
import CSV from '@salesforce/label/c.CSV';
import XML from '@salesforce/label/c.XML';
import StartDate from '@salesforce/label/c.StartDate';
import Success from '@salesforce/label/c.Success';
import EndDate from '@salesforce/label/c.EndDate';
import Back from '@salesforce/label/c.Back';
import Download from '@salesforce/label/c.Download';
import Application_xml from '@salesforce/label/c.application_xml';
import Text_csv from '@salesforce/label/c.text_csv';
import Data_xml from '@salesforce/label/c.data_xml';
import Data_csv from '@salesforce/label/c.data_csv';
import Copy from '@salesforce/label/c.Copy';
import Data_copied from '@salesforce/label/c.Data_copied';
import XML_Data from '@salesforce/label/c.XML_Data';
import CSV_Data from '@salesforce/label/c.CSV_Data';
import Error from '@salesforce/label/c.Error';
import Component_Name_Component_Type_Last_Modified_Date from '@salesforce/label/c.Component_Name_Component_Type_Last_Modified_Date';
import Kindly_input_the_end_date from '@salesforce/label/c.Kindly_input_the_end_date';
import Kindly_provide_the_start_date from '@salesforce/label/c.Kindly_provide_the_start_date';
import Please_select_Retrieve_Data from '@salesforce/label/c.Please_select_Retrieve_Data';
import The_end_date_must_be_greater_than_or_equal_to_the_start_date from '@salesforce/label/c.The_end_date_must_be_greater_than_or_equal_to_the_start_date';
import Please_input_a_end_date_that_is_earlier_than_today_s_date from '@salesforce/label/c.Please_input_a_end_date_that_is_earlier_than_today_s_date';
import Please_input_a_start_date_that_is_earlier_than_today_s_date from '@salesforce/label/c.Please_input_a_start_date_that_is_earlier_than_today_s_date';
import Please_specify_the_type_of_data_retrieval from '@salesforce/label/c.Please_specify_the_type_of_data_retrieval';
import XmlStartLabel from '@salesforce/label/c.xmlStartLabel';
import XmlEndLabel from '@salesforce/label/c.xmlEndLabel';
import Warning from '@salesforce/label/c.Warning';
import HardRefresh from '@salesforce/label/c.HardRefresh';
import No_metadata_found_between_start_date_and_end_date from '@salesforce/label/c.No_metadata_found_between_start_date_and_end_date';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class MetaDataComponentChange extends LightningElement {
    retriveData = [];
    maindata = [];
    isLoading = true;
    showFirstScreen = true;
    showSecondScreen = false;
    metaDataComponent = Meta_Morphing_Monitor;
    startDate;
    endDate;
    selectedType;
    xmlFileData;
    csvData;
    data;
    labelTextArea;
    labelButton = Submit;
    labelStartDate = StartDate;
    labelEndDate = EndDate;
    labelDownlaod = Download;
    labelCopy = Copy;
    labelRadioButton = Please_specify_the_type_of_data_retrieval;
    labelRefresh = HardRefresh;
    isError = false;
    errorMessage = '';
    get options() {
        return [{ label: CSV, value: CSV },
        { label: XML, value: XML }]
    }
    connectedCallback() {
        try {
            this.callBackend();
        } catch (error) {
            console.error(error);
        }
    }
    handleChange(event) {
        try {
            if (event.target.name == StartDate) {
                this.startDate = event.target.value;
            } else if (event.target.name == EndDate) {
                this.endDate = event.target.value;
            } else if (event.target.name == 'radioGroup') {
                this.selectedType = event.target.value;
            }
        } catch (error) {
            console.error(error);
        }
    }
    handleClick(event) {
        try {
            if (event.target.label == Submit) {
                this.isLoading = true;
                let returnData = this.validateData();
                if (returnData) {
                    this.configData();
                } else {
                    this.isLoading = false;
                }
            }
            if (event.target.label == Back) {
                this.showFirstScreen = true;
                this.showSecondScreen = false;
                this.data = [];
                this.labelTextArea = '';
                this.labelButton = Submit
            }
            if (event.target.label == Download) {
                const hiddenElement = document.createElement('a');
                hiddenElement.href = this.selectedType == XML ? Application_xml + encodeURI(this.xmlFileData) : Text_csv + encodeURI(this.csvData);
                hiddenElement.target = '_blank';
                hiddenElement.download = this.selectedType == XML ? Data_xml : Data_csv;
                hiddenElement.click();
            }
            if (event.target.label == Copy) {
                const textarea = document.createElement('textarea');
                textarea.value = this.data;
                document.body.appendChild(textarea);
                textarea.select();
                document.execCommand('copy');
                document.body.removeChild(textarea);
                this.showMessage(Data_copied, Success, Success);
            }
            if(event.target.label == this.labelRefresh){
                this.isLoading = true;
                this.callBackend();
            }

        } catch (error) {
            console.error(error);
        }
    }
    configData() {
        try {
            let completeData = [];
            this.maindata.forEach(currentItem => {
                if (currentItem.lastModifiedDate >= this.startDate && currentItem.lastModifiedDate <= this.endDate) {
                    completeData.push({
                        compName: currentItem.compName,
                        compType: currentItem.compType,
                        lastModifiedDate: currentItem.lastModifiedDate
                    });
                }
            });
            this.retriveData = this.removeDuplicates(completeData);
            if (this.retriveData.length == 0) {
                this.showMessage(No_metadata_found_between_start_date_and_end_date,Warning,Warning);
            } else {
                this.createXmlData();
                this.createCSVData();
                this.data = this.selectedType == XML ? this.xmlFileData : this.csvData;
                this.labelTextArea = this.selectedType == XML ? XML_Data : CSV_Data;
                this.showFirstScreen = false;
                this.showSecondScreen = true;
                this.labelButton = Back;
            }
            this.isLoading = false;
        } catch (error) {
            console.error(error);
        }
    }
    callBackend() {
        try {
            getAllData().then((result) => {
                if (result.isSuccess) {
                    this.maindata = JSON.parse(JSON.stringify(result.metaData));
                } else {
                    this.showFirstScreen = false;
                    this.isError = true;
                    this.errorMessage = result.message;
                }
                this.isLoading = false;
            }).catch((err) => {
                this.showMessage(err,Error,Error);
                console.error(err);
            });
        } catch (error) {
            console.error(error);
        }
    }
    createCSVData() {
        try {
            this.retriveData.sort((a, b) => {
                if (a.compType === b.compType) {
                    return a.compName.localeCompare(b.compName);
                }
                return a.compType.localeCompare(b.compType);
            });
            let headers = Component_Name_Component_Type_Last_Modified_Date;
            let rows = this.retriveData.map(item => {
                return Object.values(item).join(',');
            });
            let csvContent = headers + '\n' + rows.join('\n');
            this.csvData = csvContent;
        } catch (error) {
            console.error(error);
        }
    }
    createXmlData() {
        try {
            let types = {};
            this.retriveData.forEach(item => {
                if (!types[item.compType]) {
                    types[item.compType] = [];
                }
                types[item.compType].push(item.compName);
            });
            let xml = XmlStartLabel + '\n';
            for (let type in types) {
                xml += '\t<types>\n';
                types[type].forEach(member => {
                    xml += `\t\t<members>${member}</members>\n`;
                });
                xml += `\t\t<name>${type}</name>\n`;
                xml += '\t</types>\n';
            }
            xml += '\t' + XmlEndLabel + '\n</Package>';
            this.xmlFileData = xml;
        } catch (error) {
            console.error(error);
        }
    }
    validateData() {
        try {
            if (this.startDate == undefined || this.startDate == '') {
                this.showMessage(Kindly_provide_the_start_date, Error, Error);
                return false;
            } else if (new Date(this.startDate) > new Date()) {
                this.showMessage(Please_input_a_start_date_that_is_earlier_than_today_s_date, Error, Error);
                return false;
            } else if (this.endDate == undefined || this.endDate == '') {
                this.showMessage(Kindly_input_the_end_date, Error, Error);
                return false;
            } else if (new Date(this.endDate) > new Date()) {
                this.showMessage(Please_input_a_end_date_that_is_earlier_than_today_s_date, Error, Error);
                return false;
            } else if (new Date(this.endDate) < new Date(this.startDate)) {
                this.showMessage(The_end_date_must_be_greater_than_or_equal_to_the_start_date, Error, Error);
                return false;
            } else if (this.selectedType == undefined) {
                this.showMessage(Please_select_Retrieve_Data, Error, Error);
                return false;
            } else {
                return true;
            }
        } catch (error) {
            console.error(error);
        }
    }
    removeDuplicates(arr) {
        try {
            const uniqueArr = arr.reduce((acc, current) => {
                const existingItem = acc.find(item => item.compName === current.compName && item.compType === current.compType);
                if (!existingItem) {
                    acc.push(current);
                }
                return acc;
            }, []);
            return uniqueArr;
        } catch (error) {
            console.error(error);
        }
    }
    showMessage(message, variant, title) {
        try {
            const event = new ShowToastEvent({
                title: title,
                variant: variant,
                mode: 'dismissable',
                message: message
            });
            this.dispatchEvent(event);
        } catch (error) {
            this.consoleMessageShow(true, error);
        }
    }
}