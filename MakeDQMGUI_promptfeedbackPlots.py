#!/usr/bin/python
from ROOT import TFile, gStyle,gPad ,TObject, TCanvas, TH1, TH1F, TH2F, TLegend, TPaletteAxis, TList, TLine, TAttLine, TF1,TAxis, TPaveStats, TText, TLatex
import re
import sys, string
import ROOT
#import geometry_rendering

#This script was written for 2017 PromptFeedback Plot
#Example usage: just do python MakePlot.py DQM_V0005_R000289658__StreamExpressCosmics__Commissioning2017-Express-v1__DQMIO.root DQM_V0005_R000289658__StreamExpressCosmics__Commissioning2017-Express-v1__DQMIO.root folderWhereToSaveFiles
#Where the first root file is the run you want to check and the second root file the reference 
#Warning, the name convention is important! See the functions below.


#
##
### Start by defining useful function
##
#
partitions=["TEC", "TIB", "TID", "TOB"]
signs=["PLUS", "MINUS"]
folder="/afs/cern.ch/user/c/cctrack/scratch0/Shifter_scripts/PromptFeedback/"+sys.argv[3]
ROOT.gROOT.SetBatch(True) #no graphic output to speed up things
gStyle.SetOptTitle(1)

def getRunNumber(filename):
    pos=filename.find("__")
    runNumber_found=filename[pos-6:pos]
    #print runNumber
    return runNumber_found

def getDataset(filename):
    pos=filename.find("__")
    pos2=filename.find("__", filename.find("__") + 1)
    datasetName=filename[pos+2:pos2]
    #print dataset
    return datasetName

def GetNonZeroOccNumber(histoname):
    global nrocs
    global fin
    nrocs=0
    histo=fin.Get(histoname)
    nx=histo.GetNbinsX()
    ny=histo.GetNbinsY()
    for i in range(1,nx+1):
        for j in range(1,ny+1):
            value=histo.GetBinContent(i,j)
            if value>0:
                nrocs += 1

def produceCosmics_report(runNumber, referenceNumber, fname, ref_name, output_file):
    #the report for Cosmics
    basic_path="DQMData/Run " + runNumber
    basic_path_ref="DQMData/Run " + referenceNumber

    fin= TFile(fname)
    fin_ref= TFile(ref_name)    


    path_list = []
    path_list_ref = []
    
    #SiStrip Signal over Noise part
    #for partition in partitions:
    #
    #    if ("TEC" in partition) or ("TID" in partition):
    #        for sign in signs:
    #            path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/"+partition+"/"+sign+"/Summary_ClusterStoNCorr_OnTrack__"+partition+"__"+sign)
    #            path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/"+partition+"/"+sign+"/Summary_ClusterStoNCorr_OnTrack__"+partition+"__"+sign)
    #    else:
    #        path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/"+partition+"/Summary_ClusterStoNCorr_OnTrack__"+partition)
    #        path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/"+partition+"/Summary_ClusterStoNCorr_OnTrack__"+partition)

    path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/TIB/Summary_ClusterStoNCorr_OnTrack__TIB")
    path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/TOB/Summary_ClusterStoNCorr_OnTrack__TOB")
    path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/TEC/PLUS/Summary_ClusterStoNCorr_OnTrack__TEC__PLUS")
    path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/TEC/MINUS/Summary_ClusterStoNCorr_OnTrack__TEC__MINUS")
    path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/TID/PLUS/Summary_ClusterStoNCorr_OnTrack__TID__PLUS")
    path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/TID/MINUS/Summary_ClusterStoNCorr_OnTrack__TID__MINUS")

    path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/TIB/Summary_ClusterStoNCorr_OnTrack__TIB")
    path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/TOB/Summary_ClusterStoNCorr_OnTrack__TOB")
    path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/TEC/PLUS/Summary_ClusterStoNCorr_OnTrack__TEC__PLUS")
    path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/TEC/MINUS/Summary_ClusterStoNCorr_OnTrack__TEC__MINUS")
    path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/TID/PLUS/Summary_ClusterStoNCorr_OnTrack__TID__PLUS")
    path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/TID/MINUS/Summary_ClusterStoNCorr_OnTrack__TID__MINUS")

    #Pixel part
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/charge_PXBarrel")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/charge_PXForward")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/adc_PXBarrel")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/adc_PXForward")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_+1")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_+2")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_+3")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_-1")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_-2")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_-3")
    #path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_clusters_per_PXDisk_per_SignedBladePanel_PXRing_1")
    #path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_clusters_per_PXDisk_per_SignedBladePanel_PXRing_2")
    #path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_digis_per_PXDisk_per_SignedBladePanel_PXRing_1")
    #path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_digis_per_PXDisk_per_SignedBladePanel_PXRing_2")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_clusters_per_Lumisection_PXForward")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/size_PXForward")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_PXForward")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_per_Lumisection_PXForward")

    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_1")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_2")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_3")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_4")
    
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_clusters_per_Lumisection_PXBarrel")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/size_PXBarrel")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_PXBarrel")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_per_Lumisection_PXBarrel")

    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/charge_PXBarrel")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/charge_PXForward")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/adc_PXBarrel")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/adc_PXForward")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_+1")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_+2")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_+3")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_-1")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_-2")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_-3")
    #path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_clusters_per_PXDisk_per_SignedBladePanel_PXRing_1")
    #path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_clusters_per_PXDisk_per_SignedBladePanel_PXRing_2")
    #path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_digis_per_PXDisk_per_SignedBladePanel_PXRing_1")
    #path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_digis_per_PXDisk_per_SignedBladePanel_PXRing_2")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_clusters_per_Lumisection_PXForward")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/size_PXForward")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_PXForward")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_per_Lumisection_PXForward")


    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_1")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_2")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_3")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_4")
    
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_clusters_per_Lumisection_PXBarrel")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/size_PXBarrel")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_PXBarrel")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_per_Lumisection_PXBarrel")

    #Tracking part
    path_list.append(basic_path+"/Tracking/Run summary/TrackParameters/GeneralProperties/NumberOfTracks_CKFTk")
    path_list.append(basic_path+"/Tracking/Run summary/TrackParameters/HitProperties/NumberOfRecHitsPerTrack_CKFTk")
    path_list.append(basic_path+"/Tracking/Run summary/TrackParameters/GeneralProperties/TrackPt_CKFTk")
    path_list.append(basic_path+"/Tracking/Run summary/TrackParameters/GeneralProperties/Chi2oNDF_CKFTk")
    path_list.append(basic_path+"/Tracking/Run summary/TrackParameters/GeneralProperties/TrackPhi_CKFTk")
    path_list.append(basic_path+"/Tracking/Run summary/TrackParameters/GeneralProperties/TrackEta_CKFTk")
    
    path_list_ref.append(basic_path_ref+"/Tracking/Run summary/TrackParameters/GeneralProperties/NumberOfTracks_CKFTk")
    path_list_ref.append(basic_path_ref+"/Tracking/Run summary/TrackParameters/HitProperties/NumberOfRecHitsPerTrack_CKFTk")
    path_list_ref.append(basic_path_ref+"/Tracking/Run summary/TrackParameters/GeneralProperties/TrackPt_CKFTk")
    path_list_ref.append(basic_path_ref+"/Tracking/Run summary/TrackParameters/GeneralProperties/Chi2oNDF_CKFTk")
    path_list_ref.append(basic_path_ref+"/Tracking/Run summary/TrackParameters/GeneralProperties/TrackPhi_CKFTk")
    path_list_ref.append(basic_path_ref+"/Tracking/Run summary/TrackParameters/GeneralProperties/TrackEta_CKFTk")

    #We do a loop on all the paths. Each path is a plot we need for the prompt feedback
    for index, path in enumerate(path_list):
        print path
        histo=fin.Get(path)
        histo_ref=fin_ref.Get(path_list_ref[index])

        plotCat=""
        if "Strip" in path:
            plotCat="Strip"
        elif "Pixel" in path:
            plotCat="Pixel"
        elif "Tracking" in path:
            plotCat="Tracking"
        else:
            plotCat=""
 
        print type(histo) 
        if (type(histo) is ROOT.TH1F) or (type(histo) is ROOT.TProfile): #Handle things for TH1 histo
            c_tmp = TCanvas("c_tmp","c_tmp",1,1,1800,800)
            gStyle.SetOptStat();
            histo.Draw()
            c_tmp.Update()
            run_color = 1 #kBlack
            ref_color = 4 #kBlue
            histo.SetLineColor(run_color)
            histo.SetLineWidth(3)

            statBox = c_tmp.GetPrimitive("stats")
            statBox.SetY1NDC(0.72)
            statBox.SetY2NDC(0.97)
            statBox.SetTextColor(run_color)
            #statBox.SetFillStyle(0)#FF
            statBox.SetName(histo.GetName()) #This is super important! Or it will be lost at some point and the code will crash
            statBoxTitle = TLatex(0, 0, "    Run "+runNumber+"   ")
            statBoxTitle.SetTextColor(run_color)
            statBox.GetListOfLines().AddFirst(statBoxTitle)
            statBox.GetListOfLines().Remove(statBox.GetLineWith(histo.GetName()))
            histo.SetStats(0)
            c_tmp.Modified()
            
            if histo_ref and histo_ref.Integral() > 0:
                c_tmp2 = TCanvas("c_tmp2","c_tmp2",1,1,1800,800)
                gStyle.SetOptStat();
                histo_ref.Scale(1.*histo.Integral()/histo_ref.Integral()) #normalize histo for comparison
                histo_ref.SetLineColor(ref_color)
                histo_ref.Draw()
                histo_ref.SetLineWidth(3)
                c_tmp2.Update()

                statBox2 = c_tmp2.GetPrimitive("stats")
                statBox2.SetY1NDC(0.42);
                statBox2.SetY2NDC(0.67);
                statBox2.SetTextColor(ref_color);
                #statBox2.SetFillStyle(0)#FF
                statBox2.SetName(histo_ref.GetName()) #This is super important! Or it will be lost at some point and the code will crash
                statBoxTitle2 = TLatex(0, 0, "    Ref "+referenceNumber+"   ")
                statBoxTitle2.SetTextColor(ref_color)
                statBox2.GetListOfLines().AddFirst(statBoxTitle2)
                statBox2.GetListOfLines().Remove(statBox2.GetLineWith(histo_ref.GetName()))
                histo_ref.SetStats(0)
                c_tmp2.Modified()
          
            c_report = TCanvas("c_"+plotCat+"_"+histo.GetName(),"c_"+plotCat+"_"+histo.GetName(),1,1,1800,800)
            if histo_ref and histo_ref.Integral() > 0:
                histo.GetYaxis().SetRangeUser(histo.GetMinimum(), max(histo.GetMaximum(), histo_ref.GetMaximum())*1.1)
            histo.Draw("hist")
            if histo_ref and histo_ref.Integral() > 0:
                histo_ref.Draw("hist same")
            statBox.Draw("same")
            if histo_ref and histo_ref.Integral() > 0:
                statBox2.Draw("same")
 
            output_file.cd()
            c_report.Write()
            c_report.SaveAs(folder+"/"+plotCat+"_"+histo.GetName()+".png")

        if (type(histo) is ROOT.TH2F) or (type(histo) is ROOT.TProfile2D): #Handle things for TH2 histo
            drawOption="colz"
            c_report = TCanvas("c_"+plotCat+"_"+histo.GetName()+"_run_"+runNumber,"c_"+histo.GetName()+"_run_"+runNumber,1,1,1800,800)
            histo.Draw(drawOption)
            output_file.cd()
            c_report.Write()
            c_report.SaveAs(folder+"/"+plotCat+"_"+histo.GetName()+"_run_"+runNumber+".png")

            if histo_ref and histo_ref.Integral() > 0:            
                c_report_ref = TCanvas("c_"+plotCat+"_"+histo.GetName(),"c_"+histo.GetName()+"_ref_"+referenceNumber,1,1,1800,800)
                histo_ref.Draw(drawOption)
                output_file.cd()
                c_report_ref.Write()
                c_report_ref.SaveAs(folder+"/"+plotCat+"_"+histo.GetName()+"_ref_"+referenceNumber+".png")
            else:
	        c_report_ref = TCanvas("c_"+plotCat+"_"+histo.GetName(),"c_"+histo.GetName()+"_ref_"+referenceNumber,1,1,1800,800)
		output_file.cd()
                c_report_ref.Write()
                c_report_ref.SaveAs(folder+"/"+plotCat+"_"+histo.GetName()+"_ref_"+referenceNumber+".png")


def produceCollisions_report(runNumber, referenceNumber, fname, ref_name, output_file):
    #the report for pp collisions
    basic_path="DQMData/Run " + runNumber
    basic_path_ref="DQMData/Run " + referenceNumber
    fin= TFile(fname)
    fin_ref= TFile(ref_name)    


    path_list = []
    path_list_ref = []
    
    #SiStrip Signal over Noise part
    #for partition in partitions:
    #
    #    if ("TEC" in partition) or ("TID" in partition):
    #        for sign in signs:
    #            path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/"+partition+"/"+sign+"/Summary_ClusterStoNCorr_OnTrack__"+partition+"__"+sign)
    #            path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/"+partition+"/"+sign+"/Summary_ClusterStoNCorr_OnTrack__"+partition+"__"+sign)
    #    else:
    #        path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/"+partition+"/Summary_ClusterStoNCorr_OnTrack__"+partition)
    #        path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/"+partition+"/Summary_ClusterStoNCorr_OnTrack__"+partition)

    path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/TIB/Summary_ClusterStoNCorr_OnTrack__TIB")
    path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/TOB/Summary_ClusterStoNCorr_OnTrack__TOB")
    path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/TEC/PLUS/Summary_ClusterStoNCorr_OnTrack__TEC__PLUS")
    path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/TEC/MINUS/Summary_ClusterStoNCorr_OnTrack__TEC__MINUS")
    path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/TID/PLUS/Summary_ClusterStoNCorr_OnTrack__TID__PLUS")
    path_list.append(basic_path+"/SiStrip/Run summary/MechanicalView/TID/MINUS/Summary_ClusterStoNCorr_OnTrack__TID__MINUS")

    path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/TIB/Summary_ClusterStoNCorr_OnTrack__TIB")
    path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/TOB/Summary_ClusterStoNCorr_OnTrack__TOB")
    path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/TEC/PLUS/Summary_ClusterStoNCorr_OnTrack__TEC__PLUS")
    path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/TEC/MINUS/Summary_ClusterStoNCorr_OnTrack__TEC__MINUS")
    path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/TID/PLUS/Summary_ClusterStoNCorr_OnTrack__TID__PLUS")
    path_list_ref.append(basic_path_ref+"/SiStrip/Run summary/MechanicalView/TID/MINUS/Summary_ClusterStoNCorr_OnTrack__TID__MINUS")

    #Pixel part
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/charge_PXBarrel")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/charge_PXForward")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/adc_PXBarrel")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/adc_PXForward")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_+1")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_+2")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_+3")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_-1")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_-2")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_-3")
    #path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_clusters_per_PXDisk_per_SignedBladePanel_PXRing_1")
    #path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_clusters_per_PXDisk_per_SignedBladePanel_PXRing_2")
    #path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_digis_per_PXDisk_per_SignedBladePanel_PXRing_1")
    #path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_digis_per_PXDisk_per_SignedBladePanel_PXRing_2")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_clusters_per_Lumisection_PXForward")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/size_PXForward")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_PXForward")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_per_Lumisection_PXForward")

    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_1")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_2")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_3")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_4")
    
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_clusters_per_Lumisection_PXBarrel")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/size_PXBarrel")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_PXBarrel")
    path_list.append(basic_path+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_per_Lumisection_PXBarrel")

    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/charge_PXBarrel")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/charge_PXForward")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/adc_PXBarrel")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/adc_PXForward")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_+1")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_+2")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_+3")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_-1")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_-2")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/clusterposition_xy_PXDisk_-3")
    #path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_clusters_per_PXDisk_per_SignedBladePanel_PXRing_1")
    #path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_clusters_per_PXDisk_per_SignedBladePanel_PXRing_2")
    #path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_digis_per_PXDisk_per_SignedBladePanel_PXRing_1")
    #path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXForward/num_digis_per_PXDisk_per_SignedBladePanel_PXRing_2")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_clusters_per_Lumisection_PXForward")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/size_PXForward")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_PXForward")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_per_Lumisection_PXForward")


    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_1")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_2")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_3")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/PXBarrel/clusterposition_zphi_PXLayer_4")
    
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_clusters_per_Lumisection_PXBarrel")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/size_PXBarrel")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_PXBarrel")
    path_list_ref.append(basic_path_ref+"/PixelPhase1/Run summary/Phase1_MechanicalView/num_digis_per_Lumisection_PXBarrel")

    #Tracking part
    path_list.append(basic_path+"/Tracking/Run summary/TrackParameters/highPurityTracks/pt_1/GeneralProperties/NumberOfTracks_GenTk")
    path_list.append(basic_path+"/Tracking/Run summary/TrackParameters/HitProperties/NumberOfRecHitsPerTrack_GenTk")
    path_list.append(basic_path+"/Tracking/Run summary/TrackParameters/highPurityTracks/pt_1/GeneralProperties/TrackPt_GenTk")
    path_list.append(basic_path+"/Tracking/Run summary/TrackParameters/highPurityTracks/pt_1/GeneralProperties/Chi2oNDF_GenTk")
    path_list.append(basic_path+"/Tracking/Run summary/TrackParameters/highPurityTracks/pt_1/GeneralProperties/TrackPhi_GenTk")
    path_list.append(basic_path+"/Tracking/Run summary/TrackParameters/highPurityTracks/pt_1/GeneralProperties/TrackEta_GenTk")
    
    path_list_ref.append(basic_path_ref+"/Tracking/Run summary/TrackParameters/highPurityTracks/pt_1/GeneralProperties/NumberOfTracks_GenTk")
    path_list_ref.append(basic_path_ref+"/Tracking/Run summary/TrackParameters/HitProperties/NumberOfRecHitsPerTrack_GenTk")
    path_list_ref.append(basic_path_ref+"/Tracking/Run summary/TrackParameters/highPurityTracks/pt_1/GeneralProperties/TrackPt_GenTk")
    path_list_ref.append(basic_path_ref+"/Tracking/Run summary/TrackParameters/highPurityTracks/pt_1/GeneralProperties/Chi2oNDF_GenTk")
    path_list_ref.append(basic_path_ref+"/Tracking/Run summary/TrackParameters/highPurityTracks/pt_1/GeneralProperties/TrackPhi_GenTk")
    path_list_ref.append(basic_path_ref+"/Tracking/Run summary/TrackParameters/highPurityTracks/pt_1/GeneralProperties/TrackEta_GenTk")


	#Pixel Track Summary
    path_list.append(basic_path+ " /Pixel/Run summary/Clusters/OnTrack/charge_siPixelClusters")
    path_list.append(basic_path+ " /Pixel/Run summary/Clusters/OnTrack/size_siPixelClusters")
    path_list.append(basic_path+ " /Pixel/Run summary/Clusters/OffTrack/charge_siPixelClusters")
    path_list.append(basic_path+ " /Pixel/Run summary/Clusters/OffTrack/size_siPixelClusters")
    path_list.append(basic_path+ " /Pixel/Run summary/Tracks/ntracks_generalTracks")


    #Pixel Efficiency in Barrel
    path_list.append(basic_path+ " /Pixel/Run summary/Barrel/HitEfficiency_L1")
    path_list.append(basic_path+ " /Pixel/Run summary/Barrel/HitEfficiency_L1")
    path_list.append(basic_path+ " /Pixel/Run summary/Barrel/HitEfficiency_L1")

    #Pixel Efficiency in endcap
    path_list.append(basic_path+ " /Pixel/Run summary/Endcap/HitEfficiency_Dm1")
    path_list.append(basic_path+ " /Pixel/Run summary/Endcap/HitEfficiency_Dm2")
    path_list.append(basic_path+ " /Pixel/Run summary/Endcap/HitEfficiency_Dp1")
    path_list.append(basic_path+ " /Pixel/Run summary/Endcap/HitEfficiency_Dp2")



    #Pixel Track Summary
    path_list_ref.append(basic_path_ref+ " /Pixel/Run summary/Clusters/OnTrack/charge_siPixelClusters")
    path_list_ref.append(basic_path_ref+ " /Pixel/Run summary/Clusters/OnTrack/size_siPixelClusters")
    path_list_ref.append(basic_path_ref+ " /Pixel/Run summary/Clusters/OffTrack/charge_siPixelClusters")
    path_list_ref.append(basic_path_ref+ " /Pixel/Run summary/Clusters/OffTrack/size_siPixelClusters")
    path_list_ref.append(basic_path_ref+ " /Pixel/Run summary/Tracks/ntracks_generalTracks")


    #Pixel Efficiency in Barrel
    path_list_ref.append(basic_path_ref+ " /Pixel/Run summary/Barrel/HitEfficiency_L1")
    path_list_ref.append(basic_path_ref+ " /Pixel/Run summary/Barrel/HitEfficiency_L1")
    path_list_ref.append(basic_path_ref+ " /Pixel/Run summary/Barrel/HitEfficiency_L1")


    path_list_ref.append(basic_path_ref+ " /Pixel/Run summary/Endcap/HitEfficiency_Dm1")
    path_list_ref.append(basic_path_ref+ " /Pixel/Run summary/Endcap/HitEfficiency_Dm2")
    path_list_ref.append(basic_path_ref+ " /Pixel/Run summary/Endcap/HitEfficiency_Dp1")
    path_list_ref.append(basic_path_ref+ " /Pixel/Run summary/Endcap/HitEfficiency_Dp2")


    #We do a loop on all the paths. Each path is a plot we need for the prompt feedback
    for index, path in enumerate(path_list):
        print path
        histo=fin.Get(path)
        histo_ref=fin_ref.Get(path_list_ref[index])

        plotCat=""
        if "Strip" in path:
            plotCat="Strip"
        elif "Pixel" in path:
            plotCat="Pixel"
        elif "Tracking" in path:
            plotCat="Tracking"
        else:
            plotCat=""
 
        print type(histo) 
        if (type(histo) is ROOT.TH1F) or (type(histo) is ROOT.TProfile): #Handle things for TH1 histo
            c_tmp = TCanvas("c_tmp","c_tmp",1,1,1800,800)
            gStyle.SetOptStat()
            histo.Draw()
            c_tmp.Update()
            run_color = 1 #kBlack
            ref_color = 4 #kBlue
            histo.SetLineColor(run_color)
            histo.SetLineWidth(3)
            histo.SetStats(1)
            histo.Draw()
            c_tmp.Update()

            statBox = histo.GetListOfFunctions().FindObject("stats")
            statBox.SetY1NDC(0.72)
            statBox.SetY2NDC(0.97)
            statBox.SetTextColor(run_color)
            #statBox.SetFillStyle(0)#FF
            statBox.SetName(histo.GetName()) #This is super important! Or it will be lost at some point and the code will crash
            statBoxTitle = TLatex(0, 0, "    Run "+runNumber+"   ")
            statBoxTitle.SetTextColor(run_color)
            statBox.GetListOfLines().AddFirst(statBoxTitle)
            statBox.GetListOfLines().Remove(statBox.GetLineWith(histo.GetName()))
            histo.SetStats(0)
            c_tmp.Modified()
            
            if histo_ref and histo_ref.Integral() > 0:
                c_tmp2 = TCanvas("c_tmp2","c_tmp2",1,1,1800,800)
                gStyle.SetOptStat();
                histo_ref.Scale(1.*histo.Integral()/histo_ref.Integral()) #normalize histo for comparison
                histo_ref.SetLineColor(ref_color)
                histo_ref.Draw()
                histo_ref.SetLineWidth(3)
                c_tmp2.Update()
                histo_ref.SetStats(1)
                histo_ref.Draw()
                c_tmp2.Update()

                statBox2 = c_tmp2.GetPrimitive("stats")
                statBox2.SetY1NDC(0.42);
                statBox2.SetY2NDC(0.67);
                statBox2.SetTextColor(ref_color);
                #statBox2.SetFillStyle(0)#FF
                statBox2.SetName(histo_ref.GetName()) #This is super important! Or it will be lost at some point and the code will crash
                statBoxTitle2 = TLatex(0, 0, "    Ref "+referenceNumber+"   ")
                statBoxTitle2.SetTextColor(ref_color)
                statBox2.GetListOfLines().AddFirst(statBoxTitle2)
                statBox2.GetListOfLines().Remove(statBox2.GetLineWith(histo_ref.GetName()))
                histo_ref.SetStats(0)
                c_tmp2.Modified()
          
            c_report = TCanvas("c_"+plotCat+"_"+histo.GetName(),"c_"+plotCat+"_"+histo.GetName(),1,1,1800,800)
            if histo_ref and histo_ref.Integral() > 0:
                histo.GetYaxis().SetRangeUser(histo.GetMinimum(), max(histo.GetMaximum(), histo_ref.GetMaximum())*1.1)
            histo.Draw("hist")
            if histo_ref and histo_ref.Integral() > 0:
                histo_ref.Draw("hist same")
            statBox.Draw("same")
            if histo_ref and histo_ref.Integral() > 0:
                statBox2.Draw("same")
 
            output_file.cd()
            c_report.Write()
            c_report.SaveAs(folder+"/"+plotCat+"_"+histo.GetName()+".png")

        if (type(histo) is ROOT.TH2F) or (type(histo) is ROOT.TProfile2D): #Handle things for TH2 histo
            drawOption="colz"
            c_report = TCanvas("c_"+plotCat+"_"+histo.GetName()+"_run_"+runNumber,"c_"+histo.GetName()+"_run_"+runNumber,1,1,1800,800)
            histo.Draw(drawOption)
            output_file.cd()
            c_report.Write()
            c_report.SaveAs(folder+"/"+plotCat+"_"+histo.GetName()+"_run_"+runNumber+".png")

            if histo_ref and histo_ref.Integral() > 0:            
                c_report_ref = TCanvas("c_"+plotCat+"_"+histo.GetName(),"c_"+histo.GetName()+"_ref_"+referenceNumber,1,1,1800,800)
                histo_ref.Draw(drawOption)
                output_file.cd()
                c_report_ref.Write()
                c_report_ref.SaveAs(folder+"/"+plotCat+"_"+histo.GetName()+"_ref_"+referenceNumber+".png")
            else:
	        c_report_ref = TCanvas("c_"+plotCat+"_"+histo.GetName(),"c_"+histo.GetName()+"_ref_"+referenceNumber,1,1,1800,800)
		output_file.cd()
                c_report_ref.Write()
                c_report_ref.SaveAs(folder+"/"+plotCat+"_"+histo.GetName()+"_ref_"+referenceNumber+".png")

#
##
### The main
##
#

#get the file name
fname=sys.argv[1]
ref_name=sys.argv[2]

runNumber="0"
referenceNumber="0"
dataset=""
reference_dataset=""

#find run number
runNumber=getRunNumber(fname)
referenceNumber=getRunNumber(ref_name)

#find dataset
dataset=getDataset(fname)
reference_dataset=getDataset(ref_name)

output_file = TFile(folder+"/PromptFeedback_noTkMap_"+runNumber+"_comparedTo_"+referenceNumber+".root", "RECREATE")

#Thanks to the dataset, find which kind of PromptFeedback you want (Cosmics, pp, HI...)
if "Cosmics" in dataset:
    print "Producing report for Cosmics..."
    produceCosmics_report(runNumber, referenceNumber, fname, ref_name, output_file)
elif ("HI" in dataset) or ("PA" in dataset):
    print "Producing report for HI/PA..."
else:
    print "Producing report for pp.."
    produceCollisions_report(runNumber, referenceNumber, fname, ref_name, output_file)


